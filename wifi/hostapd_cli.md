### hostapd_cli.c

	static void wpa_request(struct wpa_ctrl *ctrl, int argc, char *argv[])
	{
	struct hostapd_cli_cmd *match = NULL;
	......
	match->handler(ctrl, argc - 1, &argv[1]);
	}
----------------------------------------------
	PATH: hostapd/hostapd_cli.c 

	  1973 int main(int argc, char *argv[])
	  1974 {
	  1975 ¦       int warning_displayed = 0;
	  1976 ¦       int c;
	  1977 ¦       int daemonize = 0;
	  1978 
	  1979 ¦       if (os_program_init())
	  1980 ¦       ¦       return -1;
	  1981 
	  1982 ¦       for (;;) {
	  1983 ¦       ¦       c = getopt(argc, argv, "a:BhG:i:p:P:s:v");
	  1984 ¦       ¦       if (c < 0)
 	  1985 ¦       ¦       ¦       break;
  	  1986 ¦       ¦       switch (c) {
	  1987 ¦       ¦       case 'a':
	  1988 ¦       ¦       ¦       action_file = optarg;
	  1989 ¦       ¦       ¦       break;
	  1990 ¦       ¦       case 'B':
	  1991 ¦       ¦       ¦       daemonize = 1;
	  1992 ¦       ¦       ¦       break;
	  1993 ¦       ¦       case 'G':
	  1994 ¦       ¦       ¦       ping_interval = atoi(optarg);
	  1995 ¦       ¦       ¦       break;
	  1996 ¦       ¦       case 'h':
	  1997 ¦       ¦       ¦       usage();
	  1998 ¦       ¦       ¦       return 0;
	  1999 ¦       ¦       case 'v':
	  2000 ¦       ¦       ¦       printf("%s\n", hostapd_cli_version);
	  2001 ¦       ¦       ¦       return 0;
	  2002 ¦       ¦       case 'i':
	  2003 ¦       ¦       ¦       os_free(ctrl_ifname);
	  2004 ¦       ¦       ¦       ctrl_ifname = os_strdup(optarg);
	  2005 ¦       ¦       ¦       break;
	  2006 ¦       ¦       case 'p':
	  2007 ¦       ¦       ¦       ctrl_iface_dir = optarg;
	  2008 ¦       ¦       ¦       break;
	  2009 ¦       ¦       case 'P':
	  2010 ¦       ¦       ¦       pid_file = optarg;
	  2011 ¦       ¦       ¦       break;
	  2012 ¦       ¦       case 's':
	  2013 ¦       ¦       ¦       client_socket_dir = optarg;
	  2014 ¦       ¦       ¦       break;
	  2015 ¦       ¦       default:
	  2016 ¦       ¦       ¦       usage();
	  2017 ¦       ¦       ¦       return -1;
	  2018 ¦       ¦       }
	  2019 ¦       }
	  2020 
	  2021 ¦       interactive = (argc == optind) && (action_file == NULL);
	  2022 
	  2023 ¦       if (interactive) {
	  2024 ¦       ¦       printf("%s\n\n%s\n\n", hostapd_cli_version, cli_license);
	  2025 ¦       }
	  2026 
	  2027 ¦       if (eloop_init())
	  2028 ¦       ¦       return -1;
	  2029 
	  2030 ¦       for (;;) {
	  2031 ¦       ¦       if (ctrl_ifname == NULL) {
	  2032 ¦       ¦       ¦       struct dirent *dent;
	  2033 ¦       ¦       ¦       DIR *dir = opendir(ctrl_iface_dir);
	  2034 ¦       ¦       ¦       if (dir) {
	  2035 ¦       ¦       ¦       ¦       while ((dent = readdir(dir))) {
	  2036 ¦       ¦       ¦       ¦       ¦       if (os_strcmp(dent->d_name, ".") == 0
	  2037 ¦       ¦       ¦       ¦       ¦           ||
   	  2038 ¦       ¦       ¦       ¦       ¦           os_strcmp(dent->d_name, "..") == 0)
	  2039 ¦       ¦       ¦       ¦       ¦       ¦       continue;
	  2040 ¦       ¦       ¦       ¦       ¦       printf("Selected interface '%s'\n",
	  2041 ¦       ¦       ¦       ¦       ¦              dent->d_name);
	  2042 ¦       ¦       ¦       ¦       ¦       ctrl_ifname = os_strdup(dent->d_name);
	  2043 ¦       ¦       ¦       ¦       ¦       break;
	  2044 ¦       ¦       ¦       ¦       }
	  2045 ¦       ¦       ¦       ¦       closedir(dir); 
	  2046 ¦       ¦       ¦       } 
	  2047 ¦       ¦       } 
	  2048 ¦       ¦       hostapd_cli_reconnect(ctrl_ifname); 
	  2049 ¦       ¦       if (ctrl_conn) { 
	  2050 ¦       ¦       ¦       if (warning_displayed)
	  2051 ¦       ¦       ¦       ¦       printf("Connection established.\n"); 
	  2052 ¦       ¦       ¦       break;
	  2053 ¦       ¦       } 
  	  2054
	  2055 ¦       ¦       if (!interactive) { 
	  2056 ¦       ¦       ¦       perror("Failed to connect to hostapd - "
	  2057 ¦       ¦       ¦              "wpa_ctrl_open"); 
	  2058 ¦       ¦       ¦       return -1;
	  2059 ¦       ¦       } 
	  2060 
	  2061 ¦       ¦       if (!warning_displayed) { 
	  2062 ¦       ¦       ¦       printf("Could not connect to hostapd - re-trying\n");
	  2063 ¦       ¦       ¦       warning_displayed = 1; 
	  2064 ¦       ¦       } 
	  2065 ¦       ¦       os_sleep(1, 0);
	  2066 ¦       ¦       continue;
	  2067 ¦       } 
	  2068 
	  2069 ¦       if (action_file && !hostapd_cli_attached)
	  2070 ¦       ¦       return -1; 
	  2071 ¦       if (daemonize && os_daemonize(pid_file) && eloop_sock_requeue())
	  2072 ¦       ¦       return -1; 
	  2073
	  2074 ¦       if (interactive)
	  2075 ¦       ¦       hostapd_cli_interactive();
	  2076 ¦       else if (action_file)
	  2077 ¦       ¦       hostapd_cli_action(ctrl_conn);
	  2078 ¦       else
	  2079 ¦       ¦       wpa_request(ctrl_conn, argc - optind, &argv[optind]);
	  2080 
	  2081 ¦       unregister_event_handler(ctrl_conn);
	  2082 ¦       os_free(ctrl_ifname);
	  2083 ¦       eloop_destroy();
	  2084 ¦       hostapd_cli_cleanup();
	  2085 ¦       return 0;
 	  2086 }
 	  
----------------------------

	hostapd_cli_reconnect()
		

