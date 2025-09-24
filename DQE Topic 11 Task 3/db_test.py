import pytest
import allure

def get_diff_or_first(result):
    if result is None or len(result) == 0:
        return None
    return result[-1]

@pytest.mark.parametrize("test_name", [
    "Completeness check for Products table",
    "Completeness check for Locations table",
    "Completeness check for Sales table"
])
@pytest.mark.smoke
def test_smoke_queries(dwh_cur, sql_tests, test_name):
    test_case = next((t for t in sql_tests if t["name"] == test_name), None)

    with allure.step(f"Executing SMOKE test: {test_case['name']}"):
        dwh_cur.execute(test_case["sql"])
        result = dwh_cur.fetchone()
        value_to_check = get_diff_or_first(result)

        assert value_to_check == test_case["expected"], (
            f"{test_case['name']} failed. "
            f"Expected {test_case['expected']}, got {value_to_check}. "
            f"Full result: {result}"
        )

@pytest.mark.parametrize("test_name", [
    "Accuracy check for Sales Quantity",
    "Accuracy check for Sales Revenue",
    "Consistency check for Missing Clients"
])
@pytest.mark.critical_path
def test_critical_queries(dwh_cur, sql_tests, test_name):
    test_case = next((t for t in sql_tests if t["name"] == test_name), None)

    with allure.step(f"Executing CRITICAL_PATH test: {test_case['name']}"):
        dwh_cur.execute(test_case["sql"])
        result = dwh_cur.fetchone()
        value_to_check = get_diff_or_first(result)

        assert value_to_check == test_case["expected"], (
            f"{test_case['name']} failed. "
            f"Expected {test_case['expected']}, got {value_to_check}. "
            f"Full result: {result}"
        )
