import pandas as pd
import pyodbc

SERVER = "localhost"
DATABASE = "EnterpriseSales_Staging"

SCHEMA = "stg"


# Tables that this profiler is allowed to inspect
ALLOWED_TABLES = {
    "Customer",
    "Product",
    "Store",
    "Employee",
    "SalesTransaction",
    "ReturnTransaction",
    "SalesTarget",
    "ProductPriceHistory"
}


# Business keys used for duplicate checking
BUSINESS_KEYS = {
    "Customer": ["CustomerID"],
    "Product": ["ProductID"],
    "Store": ["StoreID"],
    "Employee": ["EmployeeID"],
    "SalesTransaction": ["OrderID", "SourceRecordID"],
    "ReturnTransaction": ["ReturnID"],
    "SalesTarget": ["TargetDate", "StoreID", "Category"],
    "ProductPriceHistory": ["ProductID", "EffectiveDate"]
}

def greet():
    print("Welcome to the SQL Server Data Profiler!")

def create_connection():
    """
    Create a connection to SQL Server.
    """

    connection = pyodbc.connect(
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"Trusted_Connection=yes;"
    )

    return connection

def load_table(table_name):
    """
    Load a staging table into a Pandas DataFrame.
    """

    connection = create_connection()

    query = f"""
        SELECT *
        FROM {SCHEMA}.{table_name}
    """

    df = pd.read_sql(query, connection)

    connection.close()

    return df



def profile_basic(df):
    """
    Display basic information about the dataset.
    """

    print("\n" + "=" * 60)
    print("BASIC PROFILE")
    print("=" * 60)

    print(f"Rows    : {len(df):,}")
    print(f"Columns : {len(df.columns)}")

    print("\nColumns:")
    for column in df.columns:
        print(f"  - {column}")


def profile_data_types(df):
    """
    Display Pandas data types.
    """

    print("\n" + "=" * 60)
    print("DATA TYPES")
    print("=" * 60)

    for column in df.columns:
        print(f"{column:<25} {df[column].dtype}")

def profile_missing_values(df):
    """
    Check for NULL / missing values.
    """

    print("\n" + "=" * 60)
    print("MISSING VALUES")
    print("=" * 60)

    missing = df.isnull().sum()

    found_missing = False

    for column, count in missing.items():

        if count > 0:
            found_missing = True

            percentage = (count / len(df)) * 100

            print(
                f"{column:<25} "
                f"{count:>8,} "
                f"({percentage:.2f}%)"
            )

    if not found_missing:
        print("No missing values found.")

def profile_duplicate_rows(df):
    """
    Check for completely duplicated rows.
    """

    print("\n" + "=" * 60)
    print("DUPLICATE ROWS")
    print("=" * 60)

    duplicate_count = df.duplicated().sum()

    print(f"Duplicate rows: {duplicate_count:,}")


def profile_business_key(df, table_name):
    """
    Check whether the expected business key contains duplicates.
    """

    print("\n" + "=" * 60)
    print("BUSINESS KEY DUPLICATES")
    print("=" * 60)

    keys = BUSINESS_KEYS.get(table_name)

    if not keys:
        print("No business key configured.")
        return

    print(f"Business key: {', '.join(keys)}")

    duplicates = (
        df.groupby(keys)
        .size()
        .reset_index(name="Count")
    )

    duplicates = duplicates[
        duplicates["Count"] > 1
    ]

    if duplicates.empty:
        print("No duplicate business keys found.")

    else:
        print(
            f"Duplicate business key combinations: "
            f"{len(duplicates):,}"
        )

        print("\nExamples:")

        print(
            duplicates.head(10).to_string(index=False)
        )


def profile_unique_values(df):
    """
    Display number of unique values for each column.
    """

    print("\n" + "=" * 60)
    print("UNIQUE VALUES")
    print("=" * 60)

    for column in df.columns:

        unique_count = df[column].nunique(
            dropna=True
        )

        print(
            f"{column:<25} "
            f"{unique_count:>10,}"
        )

def profile_categorical_values(df):
    """
    Display common values for categorical columns.
    """

    print("\n" + "=" * 60)
    print("CATEGORICAL VALUE DISTRIBUTIONS")
    print("=" * 60)

    for column in df.select_dtypes(
        include=["object"]
    ).columns:

        unique_count = df[column].nunique(
            dropna=True
        )

        # Avoid printing huge distributions
        if unique_count <= 20:

            print(f"\n{column}")

            values = (
                df[column]
                .value_counts(dropna=False)
                .head(20)
            )

            for value, count in values.items():

                print(
                    f"  {str(value):<30} "
                    f"{count:>8,}"
                )

def profile_numeric(df):
    """
    Display statistics for numeric columns.
    """

    print("\n" + "=" * 60)
    print("NUMERIC PROFILE")
    print("=" * 60)

    numeric_columns = df.select_dtypes(
        include=["number"]
    ).columns

    if len(numeric_columns) == 0:
        print("No numeric columns found.")
        return

    for column in numeric_columns:

        series = df[column]

        print(f"\n{column}")

        print(f"  Minimum : {series.min()}")
        print(f"  Maximum : {series.max()}")
        print(f"  Mean    : {series.mean():.2f}")
        print(f"  Median  : {series.median()}")

def profile_dates(df):
    """
    Identify date columns and display their ranges.
    """

    print("\n" + "=" * 60)
    print("DATE PROFILE")
    print("=" * 60)

    date_columns = [
        column
        for column in df.columns
        if "date" in column.lower()
        or "datetime" in column.lower()
    ]

    if not date_columns:
        print("No date columns detected.")
        return

    for column in date_columns:

        dates = pd.to_datetime(
            df[column],
            errors="coerce"
        )

        valid_dates = dates.dropna()

        print(f"\n{column}")

        if valid_dates.empty:
            print("  No valid dates found.")
            continue

        print(
            f"  Minimum : "
            f"{valid_dates.min().date()}"
        )

        print(
            f"  Maximum : "
            f"{valid_dates.max().date()}"
        )

        invalid_count = dates.isna().sum()

        if invalid_count > 0:
            print(
                f"  Invalid : "
                f"{invalid_count:,}"
            )

def profile_customer_quality(df):

    print("\n" + "=" * 60)
    print("CUSTOMER DATA QUALITY CHECKS")
    print("=" * 60)

    # Age can arrive from staging as text, so coerce it safely before range checks.
    age_numeric = pd.to_numeric(df["Age"], errors="coerce")
    invalid_age = df[
        age_numeric.isna() | (age_numeric < 18) | (age_numeric > 100)
    ]

    print(
        f"\nInvalid Age records: "
        f"{len(invalid_age):,}"
    )

    today = pd.Timestamp.today().normalize()

    last_activity = pd.to_datetime(
        df["LastActivityDate"],
        errors="coerce"
    )

    future_activity = df[
        last_activity > today
    ]

    print(
        f"Future LastActivityDate records: "
        f"{len(future_activity):,}"
    )

    signup_date = pd.to_datetime(
        df["SignupDate"],
        errors="coerce"
    )

    activity_before_signup = df[
        last_activity < signup_date
    ]

    print(
        f"Activity before SignupDate records: "
        f"{len(activity_before_signup):,}"
    )


    if len(future_activity) > 0:

        print("\nExamples of future activity dates:")

        print(
            future_activity[
                [
                    "CustomerID",
                    "SignupDate",
                    "LastActivityDate"
                ]
            ]
            .head(10)
            .to_string(index=False)
        )

    if len(activity_before_signup) > 0:

        print("\nExamples of activity before signup:")

        print(
            activity_before_signup[
                [
                    "CustomerID",
                    "SignupDate",
                    "LastActivityDate"
                ]
            ]
            .head(10)
            .to_string(index=False)
        )


