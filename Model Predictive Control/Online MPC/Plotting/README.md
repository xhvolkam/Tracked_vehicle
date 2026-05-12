# Online MPC Plotting

This folder contains MATLAB plotting scripts and recorded datasets for Online MPC experiments.

## Files

| File | Description |
| --- | --- |
| `graphs_ploting.m` | Loads a selected MPC CSV file and calls the plotting helper functions. |
| `plotMPC_states.m` | Plots state trajectories such as distance and filtered velocity. |
| `plotMPC_outputs.m` | Plots output distance and reference trajectory. |
| `plotMPC_inputs.m` | Plots PWM input and input constraints. |
| `plotMPC_all.m` | Creates a combined plot of input, distance, and velocity. |
| `my_color_palette.m` | Provides shared plot colors. |
| `MPC_reference_tracking.csv` | Recorded reference tracking experiment. |
| `MPC_obstacle_tracking.csv` | Recorded obstacle tracking experiment. |
| `MPC_hard_con.csv` | Recorded hard-constraint experiment. |
| `MPC_delta_u.csv` | Recorded delta-input experiment. |

## Workflow

```text
MPC CSV log -> graphs_ploting.m -> plotMPC_* helper scripts -> figures
```

## Role In The Project

Use this folder after experiments to evaluate tracking, constraint satisfaction, velocity behavior, and command smoothness.

