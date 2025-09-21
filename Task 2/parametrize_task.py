import pytest
import yaml


def get_numbers_data(config_name):
    with open(config_name, 'r') as stream:
        config = yaml.safe_load(stream)
    return config['cases']


def add_numbers(a, b, c):
    try:
        return a + b + c
    except TypeError:
        raise TypeError('Please check the parameters. All of them must be numeric')

@pytest.mark.smoke
@pytest.mark.parametrize("a, b, c, expected", [(case['input'][0], case['input'][1], case['input'][2], case['expected'])
                                                for case in get_numbers_data("config.yaml")],
                         ids=[case['case_name'] for case in get_numbers_data("config.yaml")]
                         )
def test_add_numbers(a, b, c, expected):
    assert add_numbers(a, b, c) == expected

@pytest.mark.critical_path
def test_add_floats():
    a, b, c = 'a', 2, 1
    with pytest.raises(TypeError) as excinfo:
        add_numbers(a, b, c)
    assert "Please check the parameters. All of them must be numeric" in str(excinfo.value)