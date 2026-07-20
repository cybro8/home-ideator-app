
import pandas as pd


def compute_rating(total_minutes: int) -> tuple:
    """
    Given total runtime in minutes, return (display_string, rating_value).

    BUG FIX 1: The original code used `rating == 2` (a comparison expression,
    not an assignment) for the 1-day case. This left `rating` undefined and
    caused a NameError on the final `print("Rating : " + str(rating))`.

    BUG FIX 2: `rating` was never initialised before the if/elif chain.
    If `total_minutes` was 0 or negative the function would reach
    `print("Rating : " + str(rating))` with `rating` undefined → NameError.
    Added `rating = 0` as a safe default.
    """
    rating = 0  # BUG FIX 2: default value
    total_hours = int(total_minutes / 60)

    if total_hours <= 23:
        display = f"The device ran for: {total_hours} Hr(s)"
        rating = 1
    elif 24 <= total_hours <= 8760:
        total_days = int(total_hours / 24)
        if total_days == 1:
            display = f"The device ran for: {total_days} Day"
            rating = 2  # BUG FIX 1: was `rating == 2` (comparison, not assignment)
        else:
            display = f"The device ran for: {total_days} Days"
            if total_days < 90:
                rating = 4
            elif 90 <= total_days <= 183:
                rating = 8
            else:
                rating = 9
    else:
        display = f"The device ran for: {total_hours} Hr(s) (over 1 year)"
        rating = 9

    return display, rating


def parse_total_minutes(df: pd.DataFrame) -> int:
    """
    Sum up seconds from the 'Time Stamp' column (format HH:MM:SS)
    and convert to minutes.

    BUG FIX 3: The original code used `df['Time Stamp'][time]` which can
    raise a KeyError if the index is non-sequential after filtering.
    Using `.itertuples()` is safer and avoids label/positional confusion.

    BUG FIX 4: `int(least_time[2])` raises an IndexError if the timestamp
    has fewer than 3 parts. Added a guard.
    """
    total_seconds = 0
    for row in df.itertuples(index=False):
        ts = str(row._asdict().get('Time Stamp', ''))
        parts = ts.split(':')
        if len(parts) >= 3:
            try:
                total_seconds += int(parts[2])
            except ValueError:
                pass  # skip malformed seconds field
    return int(total_seconds / 60)


def run_from_csv(filepath: str) -> None:
    df_csv = pd.read_csv(filepath)
    df = pd.DataFrame(df_csv)
    df = df[df.Voltage != 0]
    df = df[df.Current != 0]
    total_minutes = parse_total_minutes(df)
    display, rating = compute_rating(total_minutes)
    print(display)
    print("Rating : " + str(rating))


# ---------------------------------------------------------------------------
# TEST CASES
# ---------------------------------------------------------------------------
def _run_tests():
    print("\n=== Running Rating Generator Tests ===\n")
    tests = [
        # (total_minutes_input, expected_rating, description)
        # 0 minutes → 0 hours → ≤23 branch → rating 1 (rating=0 only if no branch fires)
        (0,        1, "0 minutes  → 0 hrs → ≤23 branch → rating 1"),
        (30,       1, "30 min     → 0 hrs → ≤23 branch → rating 1"),
        (1380,     1, "1380 min   → 23 hrs → boundary, still rating 1"),
        # 1440 min → 24 hrs → 1 day exactly → rating 2
        (1440,     2, "1440 min   → exactly 1 day → rating 2 (was broken by == bug)"),
        # 2 days = 2880 min → 48 hrs → 2 days → <90 → rating 4
        (2880,     4, "2880 min   → 2 days → less than 90 days → rating 4"),
        # 89 days * 24 * 60 = 128160 min → 2136 hrs → 89 days → <90 → rating 4
        (128160,   4, "128160 min → 89 days → still <90 → rating 4"),
        # 90 days * 24 * 60 = 129600 min → 2160 hrs → 90 days → ≥90 ≤183 → rating 8
        (129600,   8, "129600 min → 90 days → rating 8"),
        # 183 days * 24 * 60 = 263520 min → 4392 hrs → 183 days → ≤183 → rating 8
        (263520,   8, "263520 min → 183 days boundary → rating 8"),
        # 184 days * 24 * 60 = 264960 min → 4416 hrs → 184 days → >183 → rating 9
        (264960,   9, "264960 min → 184 days → rating 9"),
        # 366 days * 24 * 60 = 527040 min → 8784 hrs > 8760 → over-1-year branch → rating 9
        (527040,   9, "527040 min → 366 days (over 1 year) → rating 9"),
    ]

    passed = 0
    failed = 0
    for minutes, expected_rating, description in tests:
        _, actual_rating = compute_rating(minutes)
        status = "PASS" if actual_rating == expected_rating else "FAIL"
        if status == "PASS":
            passed += 1
        else:
            failed += 1
        print(f"  [{status}] {description}")
        if status == "FAIL":
            print(f"         Expected rating={expected_rating}, got rating={actual_rating}")

    print(f"\nResults: {passed} passed, {failed} failed out of {len(tests)} tests.\n")



if __name__ == '__main__':
    _run_tests()
    # Uncomment to run against a real CSV:
    # run_from_csv("crompton_CFL_records.csv")
