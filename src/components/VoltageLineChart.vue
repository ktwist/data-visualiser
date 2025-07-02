<template>
  <div class="chart-container">
    <svg :width="width" :height="height">
      <!-- Y-axis ticks and labels -->
      <g v-for="(v, i) in yTicks" :key="'y-tick-' + i">
        <line
          :x1="padding - 5"
          :y1="v.y"
          :x2="padding"
          :y2="v.y"
          stroke="#333"
        />
        <text
          :x="padding - 10"
          :y="v.y + 4"
          text-anchor="end"
          font-size="12"
          fill="#999"
        >{{ v.value }}</text>
      </g>
      <!-- X-axis ticks and labels -->
      <g v-for="(t, i) in xTicks" :key="'x-tick-' + i">
        <line
          :x1="t.x"
          :y1="height - padding"
          :x2="t.x"
          :y2="height - padding + 5"
          stroke="#333"
        />
        <text
          :x="t.x"
          :y="height - padding + 18"
          text-anchor="middle"
          font-size="12"
          fill="#999"
        >{{ t.label }}</text>
      </g>
      <!-- Data lines -->
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
import { computed } from 'vue';

const props = defineProps<{
  transformers: TransformerAsset[];
}>();

const width = 600;
const height = 300;
const padding = 50;
const colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628'];

// Gather all voltages for scaling
const allVoltages = computed(() =>
  props.transformers.flatMap(t => t.lastTenVoltgageReadings.map(r => Number(r.voltage)))
);
const minV = computed(() => Math.min(...allVoltages.value));
const maxV = computed(() => Math.max(...allVoltages.value));

// X-axis ticks (timestamps)
const xLabels = computed(() => {
  const first = props.transformers[0]?.lastTenVoltgageReadings ?? [];
  return first.map(r => r.timestamp.slice(5, 10)); // MM-DD
});
const xTicks = computed(() => {
  const count = xLabels.value.length;
  const stepX = (width - 2 * padding) / (count - 1 || 1);
  return xLabels.value.map((label, i) => ({
    x: padding + i * stepX,
    label,
  }));
});

// Y-axis ticks (voltage values)
const yTicks = computed(() => {
  const ticks = 5;
  const values = [];
  for (let i = 0; i < ticks; i++) {
    const value = Math.round(maxV.value - ((maxV.value - minV.value) * i) / (ticks - 1));
    const y = padding + ((maxV.value - value) / (maxV.value - minV.value || 1)) * (height - 2 * padding);
    values.push({ value, y });
  }
  return values;
});

function getLinePoints(transformer: TransformerAsset) {
  const readings = transformer.lastTenVoltgageReadings;
  if (!readings.length) return '';

  const stepX = (width - 2 * padding) / (readings.length - 1 || 1);
  const range = maxV.value - minV.value;

  return readings.map((r, i) => {
    const x = padding + i * stepX;
    let y;
    if (range === 0) {
      // All voltages are the same, draw a straight line in the middle
      y = padding + (height - 2 * padding) / 2;
    } else {
      y = padding + ((maxV.value - Number(r.voltage)) / range) * (height - 2 * padding);
    }
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