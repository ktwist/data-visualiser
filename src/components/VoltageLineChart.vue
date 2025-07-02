<template>
  <div class="chart-container">
    <svg :width="width" :height="height">
      <g v-for="(t, idx) in transformers" :key="t.assetId">
        <polyline
          :points="getLinePoints(t)"
          :stroke="colors[idx % colors.length]"
          fill="none"
          stroke-width="2"
        />
      </g>
      <!-- X-axis -->
      <line :x1="padding" :y1="height - padding" :x2="width - padding" :y2="height - padding" stroke="#333" />
      <!-- Y-axis -->
      <line :x1="padding" :y1="padding" :x2="padding" :y2="height - padding" stroke="#333" />
    </svg>
    <div class="legend">
      <span v-for="(t, idx) in transformers" :key="t.assetId" :style="{ color: colors[idx % colors.length] }">
        ● {{ t.name }}
      </span>
    </div>
  </div>
</template>

<script lang="ts" setup>
import type { TransformerAsset } from '../types';

const props = defineProps<{
  transformers: TransformerAsset[];
}>();

const width = 600;
const height = 300;
const padding = 40;
const colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628'];

function getLinePoints(transformer: TransformerAsset) {
  const readings = transformer.lastTenVoltgageReadings;
  if (!readings.length) return '';

  // Find min/max for scaling
  const allVoltages = props.transformers.flatMap(t => t.lastTenVoltgageReadings.map(r => Number(r.voltage)));
  const minV = Math.min(...allVoltages);
  const maxV = Math.max(...allVoltages);

  // X step
  const stepX = (width - 2 * padding) / (readings.length - 1 || 1);

  return readings.map((r, i) => {
    const x = padding + i * stepX;
    // Invert Y axis: higher voltage = higher up
    const y = padding + ((maxV - Number(r.voltage)) / (maxV - minV || 1)) * (height - 2 * padding);
    return `${x},${y}`;
  }).join(' ');
}
</script>

<style scoped>
.chart-container {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.legend {
  margin-top: 10px;
  display: flex;
  gap: 16px;
  font-size: 14px;
}
</style>