"""
Created on Wed Sep 23 10:05:42 2020
@author: stephen
"""

import pandas as pd
import argparse
import textwrap
import numpy as np

parser = argparse.ArgumentParser(description='pool_dna_script')

parser.add_argument('-qfile', metavar='-f', type=str, default="",
                    help= textwrap.dedent('''\
                                          path to txt qubit file'''))

parser.add_argument('-nfile', metavar='-f', type=str, default="",
                    help= textwrap.dedent('''\
                                          path to csv nanodrop file'''))

parser.add_argument('-sfile', metavar='-f', type=str, default="",
                    help= textwrap.dedent('''\
                                          path to sample names file'''))

parser.add_argument('-volume', metavar='-v', nargs='+', default="35",
                    help= textwrap.dedent('''\
                                          Enter the volume (microL) of the sample, defualt is 35'''))

parser.add_argument('-poolsize', metavar='-s', nargs='+', default="6",
                    help= textwrap.dedent('''\
                                          Enter the number of samples you are pooling together, default is 6'''))

parser.add_argument('-outfile', metavar='-o', type=str, default="colony_pool_output.csv",
                    help= textwrap.dedent('''\
                                          Enter a filename to write results to, default is colony_pool_output.csv'''))

options = parser.parse_args()

#create a function which will be used later to insert blank rows
#it takes the index of the first value in the group, takes one away from this
#then inserts a blank pandas series
def f(x):
    x.loc[-1] = pd.Series([], dtype=pd.StringDtype())
    return x

def  how_much_to_take(dataframe, nanodropfile, samplenames):
    
    dataframe.rename(columns={"Original sample conc.":"Concentration (ng/microL)"}, inplace=True)
    dataframe["Volume (microL)"] = float(options.volume[0])
    dataframe["Total DNA (ng)"] = dataframe["Concentration (ng/microL)"] * dataframe["Volume (microL)"] 
    dataframe["Inverse Concentration"] = 1/dataframe["Concentration (ng/microL)"]
    dataframe["Pool Number"] = np.nan
    dataframe["Volume of sample in pool (microL)"] = np.nan
    dataframe["DNA Contributed (ng)"]= np.nan

    #The first row of the Qubit output csv file is the last sample that
    #was analysed, this is counter intuitive to analysis as you would
    #expect the first row to be the first sample analysed so the next line
    #reverses the order of the rows in the Qubit output csv.
    dataframe = dataframe.iloc[::-1].reset_index(drop=True)
    
    #make sure that pool_size input is a integer
    #and the volume input is a float (e.g could have 35.5microL )
    pool_size = int(options.poolsize[0])
    vol = float(options.volume[0])
    
    #split the dataframe by the size of your pools
    #e.g if Pool size is 6 and the dataframe has 12 Qubit entries
    #this command will get the first entry of both pools and save them to a dataframe
    pool_starts = dataframe[::pool_size]
    pool_starts = pool_starts.copy()
    
    #assign values to each first entry of the pools starting from 1 to the length of 
    #the number of pools in pool_starts
    #e.g is there are two pools then they will get numbers 1 and 2
    pool_starts["Pool Number"] = [i for i in range(1,len(pool_starts)+1)]

    #use the samplenames file to add our sample names to the pool_starts dataframe in
    #the same manner as the pool number
    pool_starts["Sample Name"] = samplenames["Sample Name"].to_numpy()
    
    #updates the dataframe[Pool] and [Sample Name] values using the pool_starts dataframe
    dataframe["Pool Number"] = pool_starts["Pool Number"]
    dataframe["Sample Name"] = pool_starts["Sample Name"]
    

    #forward fill the rest of the dataframe[Pool] column.
    #this will fill the NaNs from one Pool number to the next using the value
    #given to the group in pool_starts["Pool Number"] = [i for i in range(1,len(pool_starts)+1)]
    dataframe["Pool Number"].ffill(inplace=True)

    #forward fill the sample names column
    dataframe["Sample Name"].ffill(inplace=True)

    #create an increment column which takes the total number of samples in the group
    #divides this by 10 then adds .1 in it. This will increment the sample name by .1
    #round to 3 decimal places to prevent decimal expansion
    dataframe["Increment"] = dataframe.groupby(dataframe["Sample Name"]).cumcount()/10+.1
    dataframe["Sample Name"] = dataframe["Sample Name"] + dataframe["Increment"].round(3).astype(str).replace('^(-)0.|^0.',r'\1.',regex=True)

    #multiply the values in the inverse_conc column with the desired Pooled sample volume
    #divided by the sum of the inverse concentration of that Pool to get how much
    #volume of each sample you will contribute to the Pooled sample
    dataframe["Volume in pool (microL)"] = dataframe["Inverse Concentration"] * vol/dataframe.groupby("Pool Number")["Inverse Concentration"].transform("sum")
    
    #calculate how much dna each sample is contributing to each Pool
    #each value should be idential within pools
    dataframe["DNA Contributed (ng)"] = dataframe["Volume in pool (microL)"] * dataframe["Concentration (ng/microL)"]

    #python indexes start at 0 which will not match the samples run
    #this line reindexes the dataframe so that it starts at 1 for readability
    dataframe.index= np.arange(1,(len(dataframe)+1))
    dataframe["Sample Number"] = dataframe.index

    #add the quality scores form the nanodropfile to the dataframe
    dataframe["A260/A280"] = nanodropfile["A260/A280"].to_numpy()
    dataframe["A260/A230"] = nanodropfile["A260/A230"].to_numpy()
    
    #create a list of which headers we want in the final dataframe
    headers= ["Sample Number", "Pool Number","Volume (microL)","Concentration (ng/microL)","Total DNA (ng)","Sample Name", "Volume in pool (microL)","DNA Contributed (ng)", "A260/A280", "A260/A230"]
    
    #apply our function f to the dataframe, this adds a blank row between each pool
    #this is purely for readability 
    dataframe = dataframe.groupby("Pool Number").apply(f)

    #Save the file and print out the location it will be saved to.
    print("Saving output to file: %s" % options.outfile)
    with open(options.outfile, 'w') as output_file:
        dataframe.to_csv(output_file, columns= headers, sep=',', encoding='utf-8', index=False)

#read in qubit file
qdf = pd.read_csv(options.qfile)

#read in nanodrop file, skip first 17 rows to get to the actual header
ndf = pd.read_table(options.nfile, sep="\t", skiprows=17, usecols=["A260/A280", "A260/A230"])

#read in the sample names file
sdf = pd.read_csv(options.sfile)

#apply the function to these files
how_much_to_take(qdf, ndf, sdf)

