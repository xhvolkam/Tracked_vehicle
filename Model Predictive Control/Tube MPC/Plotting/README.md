# Tube MPC Plotting

This folder contains plotting tools and recorded data for Tube MPC experiments.

## Files

| File | Description |
| --- | --- |
| `graphs_ploting.m` | Loads the Tube MPC CSV log and calls plotting helper scripts. |
| `plotMPC_states.m` | Plots distance and velocity state trajectories. |
| `plotMPC_outputs.m` | Plots output distance and reference. |
| `plotMPC_inputs.m` | Plots input command and constraints. |
| `plotMPC_all.m` | Creates a combined input/output/state summary plot. |
| `my_color_palette.m` | Provides shared plot colors. |
| `Tube_MPC.csv` | Recorded Tube MPC experiment data. |

## Workflow

```text
Tube_MPC.csv -> graphs_ploting.m -> plotMPC_* helper scripts -> figures
```

## Role In The Project

Use this folder to inspect Tube MPC response, compare constraints, and evaluate whether the robust controller behaves as expected.

