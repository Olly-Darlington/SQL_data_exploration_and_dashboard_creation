'''
A script to run a simple two-sided z-test for proportions using the statsmodels library.
Refund count and Order counts were determined using SQL queries on the provided .csv files.
Ensure that the statsmodels library is installed in the Python environment before running this script.
'''

from statsmodels.stats.proportion import proportions_ztest

# Values adjusted for analysis in section 2.
refund_count = [91, 91]

order_count = [1288, 1004]

z_stat, p_value = proportions_ztest(
    count=refund_count,
    nobs=order_count,
    alternative="two-sided"
)

print("Z-statistic:", z_stat)
print("P-value:", p_value)