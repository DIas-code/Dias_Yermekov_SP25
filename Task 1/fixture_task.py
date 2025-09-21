import time
import pytest


@pytest.fixture(scope="session", autouse=True)
def track_suite_time():
    start = time.time()
    print('suite test started')
    yield
    end = time.time()
    print(f'suite test finished at {end - start:.2f} sec\n' )

@pytest.fixture(scope="function", autouse=True)
def track_test_time(request):
    if request.node.name == "test_add_negative_and_positive_numbers":
        yield
    else:
        start = time.time()
        print(f'function {request.node.name}  started')
        yield
        end = time.time()
        print(f'\nfunction {request.node.name} finished at {end - start:.2f} sec')

def add_numbers(a, b):
    return a + b


def test_add_two_positive_numbers():
    a, b = 3, 5
    result = add_numbers(a, b)
    time.sleep(2)
    assert result == 8


def test_add_two_negative_numbers():
    a, b = -3, -5
    result = add_numbers(a, b)
    time.sleep(3)
    assert result == -8


def test_add_negative_and_positive_numbers():
    a, b = -3, 5
    result = add_numbers(a, b)
    time.sleep(10)
    assert result == 2