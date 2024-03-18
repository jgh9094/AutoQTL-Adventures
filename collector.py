######################## IMPORTS ########################
import argparse
import pandas as pd
import sys
import os

SCHEMES = ['NSGA2', 'Lexicase']

# responsible for looking through the data directories for success
def CheckDir(dir,dump):

    # check if data dir exists
    if os.path.isdir(dir):
        print('Data dirctory exists=', dir, flush=True)
    else:
        print('DOES NOT EXIST=', dir, flush=True)
        sys.exit('DATA DIRECTORY DOES NOT EXIST')

    # collect all data
    DF_LIST = []

    for scheme in SCHEMES:
        scheme_dir = dir + scheme
        for subdir, _, _ in os.walk(scheme_dir):
            # skip root dir
            if subdir == scheme_dir:
                continue

            print('scheme_dir:',subdir)

            DF_LIST.append(pd.read_csv(subdir + '/data.csv'))

    pd.concat(DF_LIST).to_csv(path_or_buf= dump + 'scores.csv', index=False)


# runner
def main():
    # Generate and get the arguments
    parser = argparse.ArgumentParser(description="Data aggregation script.")
    parser.add_argument("data_directory", type=str,  help="Target experiment directory.")
    parser.add_argument("dump_directory", type=str,  help="Data directory where we are placing stuff at.")

    # Parse all the arguments
    args = parser.parse_args()
    data_dir = args.data_directory.strip()
    print('Data directory=',data_dir, flush=True)
    dump_directory = args.dump_directory.strip()
    print('Dump directory=',dump_directory, flush=True)

    # Get to work!
    print("\nChecking all related data directories now!", flush=True)
    CheckDir(data_dir,dump_directory)

if __name__ == "__main__":
    main()