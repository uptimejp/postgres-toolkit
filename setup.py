from setuptools import setup, find_packages

setup(
    name = "postgres-toolkit",
    version = "0.3.0",
    packages=find_packages(),

    entry_points = {
        'console_scripts': [
            'pt-config = postgres_toolkit.pt_config:main',
            'pt-index-usage = postgres_toolkit.pt_index_usage:main',
            'pt-kill = postgres_toolkit.pt_kill:main',
            'pt-privilege-autogen = postgres_toolkit.pt_privilege_autogen:main',
            'pt-proc-stat = postgres_toolkit.pt_proc_stat:main',
            'pt-replication-stat = postgres_toolkit.pt_replication_stat:main',
            'pt-session-profiler = postgres_toolkit.pt_session_profiler:main',
            'pt-set-tablespace = postgres_toolkit.pt_set_tablespace:main',
            'pt-show-locks = postgres_toolkit.pt_show_locks:main',
            'pt-snap-statements = postgres_toolkit.pt_snap_statements:main',
            'pt-stat-snapshot = postgres_toolkit.pt_stat_snapshot:main',
            'pt-table-usage = postgres_toolkit.pt_table_usage:main',
            'pt-tablespace-usage = postgres_toolkit.pt_tablespace_usage:main',
            'pt-xact-stat = postgres_toolkit.pt_xact_stat:main',
            'pt-verify-checksum = postgres_toolkit.pt_verify_checksum:main',
        ]
    },

    scripts = ['src/pt-archive-xlog/pt-archive-xlog']
)
