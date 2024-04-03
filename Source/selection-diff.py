import pandas as pd # for data loading and manipulation
from sklearn.model_selection import train_test_split # for splitting the datasets as required
import matplotlib.pyplot as plt # for visualization

from autoqtl import AUTOQTLRegressor # for running autoqtl
import numpy as np
import pandas as pd
import argparse
import os

# to run locally and with updated changes: pip install -e ./lexicase-base; clear; python selection-diff.py --selection Lexicase --seed 1 --savepath ./

def main():
    # read in arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--selection",  default='NSGA2',  type=str)
    parser.add_argument("--seed",       default=1,        type=int)
    parser.add_argument("--savepath",   default="./",     type=str)
    parser.add_argument("--data",   default="./",     type=str)

    # Parse all the arguments and print
    args = parser.parse_args()
    print('selection scheme:', args.selection)
    print('seed:', args.seed)
    print('save path:', args.savepath)

    # read the sample data
    data = pd.read_csv("sample_data.csv") # change the data path as required

    # extract the features and target
    features = data.iloc[:,:-1] # all the columns except the last column
    target = data.iloc[:,-1] # the last column

    # split the data into 80-20, use 20 as holdout and 80 for running autoqtl
    features_80, features_20, target_80, target_20 = train_test_split(features, target, test_size=0.2, random_state=42)

    # Initializing the autoqtl object using the AUTOQTLRegressor class
    autoqtl_object = AUTOQTLRegressor(population_size=100, generations=100, verbosity=2, random_state=int(args.seed), selection=args.selection)

    # calling the fit function
    autoqtl_object.fit(features= features_80, target= target_80, random_state= 42, test_size= 0.5)

    # get pareto front
    front = autoqtl_object.get_pareto_front()

    r2 = []

    for pipeline, pipeline_scores in zip(front.items, reversed(front.keys)):
        r2.append(pipeline_scores.wvalues[0])

    idx = []
    model = 0

    # print('r2:', r2)

    for pipeline, pipeline_scores in zip(front.items, reversed(front.keys)):
        if pipeline_scores.wvalues[0] == np.max(r2):
            idx.append(pipeline)
    # print('idx:',idx)
    # print()

    diff = []
    for pipeline, pipeline_scores in zip(front.items, reversed(front.keys)):
        if pipeline in idx:
            diff.append(pipeline_scores.wvalues[1])
    # print('diff:',diff)
    # print()

    final = []
    for pipeline, pipeline_scores in zip(front.items, reversed(front.keys)):
        if (pipeline in idx) and (pipeline_scores.wvalues[1] == np.max(diff)):
            final.append(pipeline)
    # print('final:',final)
    # print()

    if len(final) > 1:
        model =  np.choose(final)
    else:
        model = final[0]

    print('pipeline:', model)
    print()

    # print('autoqtl_object.get_pareto_front():')
    # print(type(autoqtl_object.get_pareto_front()))
    # for p in autoqtl_object.get_pareto_front():
    #     print(p)
    # print()

    model_id = 1
    for p in autoqtl_object.get_pareto_front():
        if p == model:
            break
        model_id += 1

    print('model_id:',model_id)
    holdout_score = autoqtl_object.score_user_choice(features_20, target_20, model_id)
    print('holdout score:', holdout_score)

    print('CREATING DIRECTORY')
    os.makedirs(args.savepath)
    print("SUCCESSFULLY CREATED:",args.savepath)

    autoqtl_object.plot_final_pareto().savefig(args.savepath + '/front.png')

    # save the scores
    data = [ [args.selection, holdout_score]]
    df = pd.DataFrame(data, columns=['Scheme', 'Score'])
    df.to_csv(args.savepath + '/data.csv', index=False)

if __name__ == '__main__':
    main()