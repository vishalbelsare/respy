#!/usr/bin/env python
""" This script allows to modify parameter values.

    Example:

        respy-modify --fix --identifiers 1-5 5-9
        respy-modify --identifiers 1 --action bounds --bounds 0.0 1.0

"""
import argparse
import shutil
import os

from respy.python.shared.shared_auxiliary import dist_class_attributes
from respy.python.shared.shared_auxiliary import cholesky_to_coeffs
from respy.python.shared.shared_auxiliary import get_optim_paras
from respy.python.shared.shared_auxiliary import print_init_dict
from respy.python.read.read_python import read
from respy import RespyCls


def dist_input_arguments(parser):
    """ Check input for script.
    """
    # Parse arguments
    args = parser.parse_args()

    # Distribute arguments
    identifiers = args.identifiers
    init_file = args.init_file
    values = args.values
    action = args.action
    bounds = args.bounds

    # Special processing for identifiers to allow to pass in ranges.
    identifiers_list = []
    for identifier in identifiers:
        is_range = ('-' in identifier)
        if is_range:
            identifier = identifier.split('-')
            assert (len(identifier) == 2)
            identifier = [int(val) for val in identifier]
            identifier = list(range(identifier[0], identifier[1] + 1))
        else:
            identifier = [int(identifier)]

        identifiers_list += identifier

    # Check duplicates
    assert (len(set(identifiers_list)) == len(identifiers_list))

    # Checks
    assert os.path.exists(init_file)
    assert isinstance(identifiers, list)

    if values is not None:
        assert isinstance(values, list)
        assert (len(values) == len(identifiers_list))
    # Implications
    if action in ['free', 'fix', 'bounds']:
        assert (values is None)
        assert os.path.exists(init_file)

    if action in ['bounds']:
        assert bounds is not None
        assert len(identifiers) == 1
        for i in range(2):
            if bounds[i].upper() == 'NONE':
                bounds[i] = None
            else:
                bounds[i] = float(bounds[i])

    # Finishing
    return identifiers_list, action, init_file, values, bounds


def scripts_modify(identifiers, action, init_file, values=None, bounds=None):
    """ Modify optimization parameters by either changing their status or values.
    """
    # Select interface
    is_bounds = (action == 'bounds')
    is_fixed = (action == 'fix')

    # Baseline
    init_dict = read(init_file)
    respy_obj = RespyCls(init_file)

    optim_paras, num_paras, num_types = dist_class_attributes(respy_obj, 'optim_paras',
        'num_paras', 'num_types')

    # We now need to ensure a consistent perspective, i.e. all are the parameter values as
    # specified in the initialization file.
    x = get_optim_paras(optim_paras, num_paras, 'all', True)
    x[44:54] = cholesky_to_coeffs(optim_paras['shocks_cholesky'])

    if action == 'value':
        for i, j in enumerate(identifiers):
            x[j] = values[i]

    for identifier in identifiers:
        if identifier in [0]:
            j = identifier
            init_dict['BASICS']['coeffs'][j] = x[identifier]
            if is_fixed:
                init_dict['BASICS']['fixed'][j] = is_fixed
            elif is_bounds:
                init_dict['BASICS']['bounds'][j] = bounds
        elif identifier in [1]:
            j = identifier - 1
            init_dict['AMBIGUITY']['coeffs'][j] = x[identifier]
            if is_fixed:
                init_dict['AMBIGUITY']['fixed'][j] = is_fixed
            elif is_bounds:
                init_dict['AMBIGUITY']['bounds'][j] = bounds
        elif identifier in list(range(2, 4)):
            j = identifier - 2
            init_dict['COMMON']['coeffs'][j] = x[identifier]
            if is_fixed:
                init_dict['COMMON']['fixed'][j] = is_fixed
            elif is_bounds:
                init_dict['COMMON']['bounds'][j] = bounds
        elif identifier in list(range(4, 19)):
            j = identifier - 4
            init_dict['OCCUPATION A']['coeffs'][j] = x[identifier]
            if is_fixed:
                init_dict['OCCUPATION A']['fixed'][j] = is_fixed
            elif is_bounds:
                init_dict['OCCUPATION A']['bounds'][j] = bounds
        elif identifier in list(range(19, 34)):
            j = identifier - 19
            init_dict['OCCUPATION B']['coeffs'][j] = x[identifier]
            if is_fixed:
                init_dict['OCCUPATION B']['fixed'][j] = is_fixed
            elif is_bounds:
                init_dict['OCCUPATION B']['bounds'][j] = bounds
        elif identifier in list(range(34, 41)):
            j = identifier - 34
            init_dict['EDUCATION']['coeffs'][j] = x[identifier]
            if is_fixed:
                init_dict['EDUCATION']['fixed'][j] = is_fixed
            elif is_bounds:
                init_dict['EDUCATION']['bounds'][j] = bounds
        elif identifier in list(range(41, 44)):
            j = identifier - 41
            init_dict['HOME']['coeffs'][j] = x[identifier]
            if is_fixed:
                init_dict['HOME']['fixed'][j] = is_fixed
            elif is_bounds:
                init_dict['HOME']['bounds'][j] = bounds
        elif identifier in list(range(44, 54)):
            j = identifier - 44
            init_dict['SHOCKS']['coeffs'][j] = x[identifier]
            if is_fixed:
                init_dict['SHOCKS']['fixed'][j] = is_fixed
            elif is_bounds:
                init_dict['SHOCKS']['bounds'][j] = bounds
        elif identifier in list(range(54, 54 + (num_types - 1) * 2)):
            j = identifier - 54
            init_dict['TYPE SHARES']['coeffs'][j] = x[identifier]
            if is_fixed:
                init_dict['TYPE SHARES']['fixed'][j] = is_fixed
            elif is_bounds:
                init_dict['TYPE SHARES']['bounds'][j] = bounds
        elif identifier in list(range(54 + (num_types - 1) * 2, num_paras)):
            j = identifier - (54 + (num_types - 1) * 2)
            init_dict['TYPE SHIFTS']['coeffs'][j] = x[identifier]
            if is_fixed:
                init_dict['TYPE SHIFTS']['fixed'][j] = is_fixed
            elif is_bounds:
                init_dict['TYPE SHIFTS']['bounds'][j] = bounds
        else:
            raise NotImplementedError

    # Check that the new candidate initialization file is valid. If so, go ahead and replace the
    # original file.
    print_init_dict(init_dict, '.tmp.respy.ini')
    RespyCls('.tmp.respy.ini')
    shutil.move('.tmp.respy.ini', init_file)


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Modify parameter values for an estimation.')

    parser.add_argument('--identifiers', action='store', dest='identifiers', nargs='*',
                        default=None, help='parameter identifiers', required=True)

    parser.add_argument('--values', action='store', dest='values', nargs='*', default=None,
                        help='updated parameter values', type=float)

    parser.add_argument('--bounds', action='store', dest='bounds', nargs=2, default=None,
                        help='bounds for parameter value')

    parser.add_argument('--action', action='store', dest='action', default=None,
                        help='requested action', type=str, required=True,
                        choices=['fix', 'free', 'value', 'bounds'])

    parser.add_argument('--init', action='store', dest='init_file', default='model.respy.ini',
                        help='initialization file')

    # Process command line arguments
    args = dist_input_arguments(parser)

    # Run modifications
    scripts_modify(*args)