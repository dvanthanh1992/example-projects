import os
import json
import statistics


class ReportGenerator:
    """Class to generate and save load test reports."""

    @staticmethod
    def generate_report(results, start_time, end_time, errors, session_count):
        """
        Analyze test results and generate a summary report.

        Args:
            results (list): List of performance metrics from all sessions.
            start_time (datetime): Test start time.
            end_time (datetime): Test end time.
            errors (list): Errors occurred during testing.
            session_count (int): Total number of user sessions.

        Returns:
            dict: Summary report.
        """
        # Ensure the 'reports' directory exists
        reports_dir = "reports"
        os.makedirs(reports_dir, exist_ok=True)

        # Generate the report filename with timestamp
        timestamp = start_time.strftime("%d-%m-%Y_%Hh-%Mm-%Ss")
        report_filename = os.path.join(
            reports_dir, f"load_test_report_{timestamp}.json"
        )

        # Extract statistics from results
        total_times = [r["total_time"] for r in results if "total_time" in r]
        load_times = [r["load_time"] for r in results if "load_time" in r]

        # Prepare the report content
        report = {
            "Report files": report_filename,
            "Time": timestamp,
            "Total number of user sessions running at the same time": session_count,
            "Total testing time": str(end_time - start_time),
            "Total websites visited": len(results),  # Total number of websites visited
            "Average time when a website responds": round(
                statistics.mean(total_times), 2
            ),
            "Errors": errors,
        }

        # Save the report to a file
        with open(report_filename, "w") as f:
            json.dump(report, f, indent=4)

        return report
