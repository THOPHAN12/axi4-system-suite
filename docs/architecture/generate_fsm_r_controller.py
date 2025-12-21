#!/usr/bin/env python3
"""
Generate FSM diagram for Read Data (R) Channel Controller
Based on Controller.sv implementation
Style matches AR Channel Controller FSM (sequential vertical layout)
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Circle
import numpy as np

# Set figure size (matching AR FSM)
fig, ax = plt.subplots(1, 1, figsize=(14, 10))
ax.set_xlim(0, 14)
ax.set_ylim(0, 10)
ax.axis('off')

# Color scheme matching AR FSM
colors = {
    'idle': '#FFFFFF',      # White - IDLE
    'wait': '#90EE90',      # Light Green - WAIT states
    'arbitrate': '#87CEEB', # Sky Blue - ARBITRATE
    'decode': '#FFD700',    # Gold/Yellow - DECODE
    'transfer': '#FF6B6B',  # Red - TRANSFER
    'wait_ready': '#D3D3D3',# Light Gray - WAIT_READY
}

# State positions (vertical sequential layout like AR FSM)
# Main flow down the center
states = {
    'IDLE': (7, 9),
    'WAIT_DATA': (7, 7.8),
    'DECODE': (7, 6.6),
    'ROUTE_S0': (3, 5),
    'ROUTE_S1': (6, 5),
    'ROUTE_S2': (8, 5),
    'ROUTE_S3': (11, 5),
    'TRANSFER': (7, 3.5),
    'WAIT_LAST': (7, 2),
}

# Draw state function (matching AR FSM style)
def draw_state(ax, pos, name, color, size=(1.8, 0.8)):
    x, y = pos
    # Draw rounded rectangle
    box = FancyBboxPatch((x - size[0]/2, y - size[1]/2), 
                         size[0], size[1],
                         boxstyle="round,pad=0.15",
                         facecolor=color,
                         edgecolor='black',
                         linewidth=2.5)
    ax.add_patch(box)
    # Add text
    ax.text(x, y, name, ha='center', va='center', 
            fontsize=10, fontweight='bold')

# Draw states with appropriate colors
draw_state(ax, states['IDLE'], 'IDLE', colors['idle'])
draw_state(ax, states['WAIT_DATA'], 'WAIT_DATA', colors['wait'])
draw_state(ax, states['DECODE'], 'DECODE\nSLAVE', colors['decode'])
draw_state(ax, states['ROUTE_S0'], 'ROUTE\nSLAVE0', colors['decode'], size=(1.5, 0.7))
draw_state(ax, states['ROUTE_S1'], 'ROUTE\nSLAVE1', colors['decode'], size=(1.5, 0.7))
draw_state(ax, states['ROUTE_S2'], 'ROUTE\nSLAVE2', colors['decode'], size=(1.5, 0.7))
draw_state(ax, states['ROUTE_S3'], 'ROUTE\nSLAVE3', colors['decode'], size=(1.5, 0.7))
draw_state(ax, states['TRANSFER'], 'TRANSFER', colors['transfer'])
draw_state(ax, states['WAIT_LAST'], 'WAIT_LAST', colors['wait_ready'])

# Draw arrow function
def draw_arrow(ax, start, end, label='', color='black', style='->', 
               label_pos='center', curve=0):
    x1, y1 = start
    x2, y2 = end
    
    # Calculate direction
    dx = x2 - x1
    dy = y2 - y1
    length = np.sqrt(dx**2 + dy**2)
    
    if length > 0:
        # Offset start and end points to avoid overlapping with boxes
        offset = 0.45
        x1_offset = x1 + (dx/length) * offset
        y1_offset = y1 + (dy/length) * offset
        x2_offset = x2 - (dx/length) * offset
        y2_offset = y2 - (dy/length) * offset
        
        # Connection style
        conn_style = f"arc3,rad={curve}" if curve != 0 else None
        
        # Draw arrow
        arrow = FancyArrowPatch((x1_offset, y1_offset), (x2_offset, y2_offset),
                               arrowstyle='->', color=color, linewidth=2,
                               connectionstyle=conn_style)
        ax.add_patch(arrow)
        
        # Add label
        if label:
            if label_pos == 'center':
                mid_x = (x1_offset + x2_offset) / 2
                mid_y = (y1_offset + y2_offset) / 2
            elif label_pos == 'start':
                mid_x = x1_offset + (x2_offset - x1_offset) * 0.3
                mid_y = y1_offset + (y2_offset - y1_offset) * 0.3
            else:  # 'end'
                mid_x = x1_offset + (x2_offset - x1_offset) * 0.7
                mid_y = y1_offset + (y2_offset - y1_offset) * 0.7
            
            ax.text(mid_x, mid_y + 0.2, label, ha='center', va='bottom',
                   fontsize=8, color=color,
                   bbox=dict(boxstyle='round,pad=0.3', 
                   facecolor='white', edgecolor='none', alpha=0.9))

# Draw self-loop function
def draw_self_loop(ax, pos, label='', color='black', side='right'):
    x, y = pos
    radius = 0.5
    
    if side == 'right':
        center_x = x + 1.2
        angle_start = 0
    else:  # left
        center_x = x - 1.2
        angle_start = 180
    
    # Create circle for self-loop
    circle = Circle((center_x, y), radius, fill=False, 
                   edgecolor=color, linewidth=2)
    ax.add_patch(circle)
    
    # Draw arrow on circle
    arrow_angle = angle_start + 45
    arrow_x = center_x + radius * np.cos(np.radians(arrow_angle))
    arrow_y = y + radius * np.sin(np.radians(arrow_angle))
    
    arrow = FancyArrowPatch(
        (center_x + radius * np.cos(np.radians(arrow_angle - 30)), 
         y + radius * np.sin(np.radians(arrow_angle - 30))),
        (arrow_x, arrow_y),
        arrowstyle='->', color=color, linewidth=2)
    ax.add_patch(arrow)
    
    # Add label
    if label:
        label_x = center_x + radius * 1.5 if side == 'right' else center_x - radius * 1.5
        ax.text(label_x, y, label, ha='left' if side == 'right' else 'right', 
               va='center', fontsize=8, color=color,
               bbox=dict(boxstyle='round,pad=0.3', 
               facecolor='white', edgecolor='none', alpha=0.9))

# Main flow (matching AR FSM style)
# IDLE -> WAIT_DATA
draw_arrow(ax, states['IDLE'], states['WAIT_DATA'], 
           'Mx_ARVALID', color='blue')

# WAIT_DATA -> DECODE
draw_arrow(ax, states['WAIT_DATA'], states['DECODE'], 
           'Sx_ARREADY', color='green')

# DECODE -> ROUTE (4 branches based on address)
draw_arrow(ax, states['DECODE'], states['ROUTE_S0'], 
           'addr→S0', color='purple', label_pos='start')
draw_arrow(ax, states['DECODE'], states['ROUTE_S1'], 
           'addr→S1', color='purple', label_pos='center')
draw_arrow(ax, states['DECODE'], states['ROUTE_S2'], 
           'addr→S2', color='purple', label_pos='center')
draw_arrow(ax, states['DECODE'], states['ROUTE_S3'], 
           'addr→S3', color='purple', label_pos='start')

# ROUTE -> TRANSFER
draw_arrow(ax, states['ROUTE_S0'], states['TRANSFER'], 
           '', color='black', curve=-0.15)
draw_arrow(ax, states['ROUTE_S1'], states['TRANSFER'], 
           '', color='black')
draw_arrow(ax, states['ROUTE_S2'], states['TRANSFER'], 
           '', color='black')
draw_arrow(ax, states['ROUTE_S3'], states['TRANSFER'], 
           '', color='black', curve=0.15)

# TRANSFER -> WAIT_LAST
draw_arrow(ax, states['TRANSFER'], states['WAIT_LAST'], 
           'Mx_RREADY &&\nSx_RVALID', color='orange')

# WAIT_LAST -> IDLE (when RLAST)
draw_arrow(ax, states['WAIT_LAST'], states['IDLE'], 
           'RLAST', color='red', curve=-0.3)

# WAIT_LAST -> TRANSFER (burst continues, !RLAST)
draw_arrow(ax, states['WAIT_LAST'], states['TRANSFER'], 
           '!RLAST', color='orange', curve=-0.3)

# Add title
ax.text(7, 9.7, 'Read Data (R) Channel Controller FSM', 
        ha='center', va='top', fontsize=16, fontweight='bold')

# Add subtitle
ax.text(7, 9.35, 'Routes read data from selected slave to requesting master', 
        ha='center', va='top', fontsize=10, style='italic')

# Add legend (matching AR FSM style)
legend_elements = [
    mpatches.Patch(facecolor=colors['idle'], edgecolor='black', label='IDLE'),
    mpatches.Patch(facecolor=colors['wait'], edgecolor='black', label='WAIT'),
    mpatches.Patch(facecolor=colors['decode'], edgecolor='black', label='DECODE/ROUTE'),
    mpatches.Patch(facecolor=colors['transfer'], edgecolor='black', label='TRANSFER'),
    mpatches.Patch(facecolor=colors['wait_ready'], edgecolor='black', label='WAIT_LAST'),
]
ax.legend(handles=legend_elements, loc='lower center', ncol=5, 
         bbox_to_anchor=(0.5, 0.01), fontsize=9, frameon=True)

# Add notes box
notes = [
    "• Address decode determines which slave (S0-S3) to route from",
    "• RLAST signal indicates end of burst transaction",
    "• Loop between TRANSFER ↔ WAIT_LAST handles burst data beats",
    "• Works independently for Master 0 and Master 1"
]
note_text = '\n'.join(notes)
ax.text(7, 0.8, note_text, ha='center', va='top', fontsize=8,
       bbox=dict(boxstyle='round,pad=0.4', facecolor='wheat', 
       edgecolor='black', alpha=0.8))

plt.tight_layout()
plt.savefig('fsm_r_controller.png', dpi=300, bbox_inches='tight', facecolor='white')
print("FSM diagram saved as fsm_r_controller.png")
plt.close()
