import pandas as pd
import numpy as np

from respy.python.process.process_auxiliary import check_dataset_est
from respy.python.shared.shared_constants import FORMATS_DICT
from respy.python.shared.shared_constants import LABELS


def process(respy_obj):
    """ This function processes the dataset from disk.
    """
    # Distribute class attributes
    num_agents_est = respy_obj.get_attr('num_agents_est')
    file_est = respy_obj.get_attr('file_est')

    # Process dataset from files.
    data_frame = pd.read_csv(file_est, delim_whitespace=True, header=-1,
        na_values='.', dtype=FORMATS_DICT, names=LABELS)

    # We now subset the dataframe to include only the number of agents that
    # are requested for the estimation.
    data_frame.set_index(['Identifier'], drop=False, inplace=True)
    drop_indices = data_frame.index.unique()[num_agents_est:]
    data_frame.drop(drop_indices, inplace=True)

    # We want to make sure that the dataset contains exactly the number of
    # agents that were requested. This might not necessarily be the case
    # if a user requests an estimation with more agents than available. This
    # cannot be part of the check_dataset_est() function that is also called
    # by simulate().
    dat = len(data_frame['Identifier'].unique())
    np.testing.assert_equal(dat, num_agents_est)

    data_frame.set_index(['Identifier', 'Period'], drop=False, inplace=True)

    # Check the dataset against the initialization files.
    check_dataset_est(data_frame, respy_obj)

    # Finishing
    return data_frame

