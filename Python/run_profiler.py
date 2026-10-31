import argparse
import data_profiler as profiler


def run_profiler(table_name):
    print("\n" + "#" * 60)
    print(f"DATA PROFILING: {profiler.SCHEMA}.{table_name}")
    print("#" * 60)

    df = profiler.load_table(table_name)


    profiler.profile_basic(df)
    profiler.profile_data_types(df)
    profiler.profile_missing_values(df)
    profiler.profile_duplicate_rows(df)
    profiler.profile_business_key(df, table_name)
    profiler.profile_unique_values(df)
    profiler.profile_categorical_values(df)
    profiler.profile_numeric(df)
    profiler.profile_dates(df)

    if table_name == "Customer":
        profiler.profile_customer_quality(df)


def main():
    parser = argparse.ArgumentParser(description="Reusable SQL Server data profiler")


    parser.add_argument("table", help="Name of the source table to profile")

    args = parser.parse_args()
    table_name = args.table

    if table_name not in profiler.ALLOWED_TABLES:
        parser.error(
            f"Invalid table '{table_name}'. "
            f"Allowed tables: {', '.join(sorted(profiler.ALLOWED_TABLES))}"
        )

    run_profiler(table_name)

if __name__ == "__main__":
    main()
