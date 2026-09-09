#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <mach/mach.h>
#include <stdbool.h>
#include <time.h>

#define MAX_TOPPROC_LEN 14

static const char TOPPROC[] = { "/bin/ps -Aceo pcpu,comm -r" }; 
static const char FILTER_PATTERN[] = { "com.apple." };

struct cpu {
  host_t host;
  mach_msg_type_number_t count;
  host_cpu_load_info_data_t load;
  host_cpu_load_info_data_t prev_load;
  bool has_prev_load;

  char command[512];
};

static inline void cpu_init(struct cpu* cpu) {
  cpu->host = mach_host_self();
  cpu->count = HOST_CPU_LOAD_INFO_COUNT;
  cpu->has_prev_load = false;
  snprintf(cpu->command, 512, "");
}

static inline void cpu_update(struct cpu* cpu) {
  kern_return_t error = host_statistics(cpu->host,
                                        HOST_CPU_LOAD_INFO,
                                        (host_info_t)&cpu->load,
                                        &cpu->count                );

  if (error != KERN_SUCCESS) {
    printf("Error: Could not read cpu host statistics.\n");
    return;
  }

  if (cpu->has_prev_load) {
    uint32_t delta_user = cpu->load.cpu_ticks[CPU_STATE_USER]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_USER];

    uint32_t delta_system = cpu->load.cpu_ticks[CPU_STATE_SYSTEM]
                            - cpu->prev_load.cpu_ticks[CPU_STATE_SYSTEM];

    uint32_t delta_idle = cpu->load.cpu_ticks[CPU_STATE_IDLE]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_IDLE];

    double user_perc = (double)delta_user / (double)(delta_system
                                                     + delta_user
                                                     + delta_idle);

    double sys_perc = (double)delta_system / (double)(delta_system
                                                      + delta_user
                                                      + delta_idle);

    double total_perc = user_perc + sys_perc;

    FILE* file;
    char line[1024];

    file = popen(TOPPROC, "r");
    if (!file) {
      printf("Error: TOPPROC command errored out...\n" );
      return;
    }

    fgets(line, sizeof(line), file); // skip header
    fgets(line, sizeof(line), file); // top process line
    pclose(file);

    // Parse: "  PID  %CPU COMMAND"  ->  extract %cpu and comm
    float top_pcpu = 0.0f;
    char  top_comm[256] = {0};
    // ps output columns: pcpu  comm
    sscanf(line, " %f %255s", &top_pcpu, top_comm);

    // Strip com.apple. prefix if present
    char* comm_start = top_comm;
    char* apple_prefix = strstr(top_comm, FILTER_PATTERN);
    if (apple_prefix) comm_start = apple_prefix + strlen(FILTER_PATTERN);

    // Truncate to MAX_TOPPROC_LEN
    char topproc[MAX_TOPPROC_LEN + 4];
    snprintf(topproc, sizeof(topproc), "%.*s", MAX_TOPPROC_LEN, comm_start);

    // Label color based on total CPU load
    const char* color;
    if (total_perc >= .7) {
      color    = getenv("RED");
    } else if (total_perc >= .3) {
      color    = getenv("ORANGE");
    } else if (total_perc >= .1) {
      color    = getenv("YELLOW");
    } else {
      color    = getenv("LABEL_COLOR");
    }

    if (!color)    color    = "0xffe6edf3";

    snprintf(cpu->command, 512,
             "--set cpu.percent label=%.0f%% label.color=%s ",
             total_perc * 100.,
             color);
  }
  else {
    snprintf(cpu->command, 256, "");
  }

  cpu->prev_load = cpu->load;
  cpu->has_prev_load = true;
}
