<template>
  <div class="chart-container" style="position: relative;">
    <!-- Always visible info box below chart -->
    <div>
      <svg :width="width" :height="height" @mousemove="onMouseMove" @mouseleave="onMouseLeave">
        <!-- Y-axis ticks and labels -->
        <g v-for="(v, i) in yTicks" :key="'y-tick-' + i">
          <line :x1="padding - 5" :y1="v.y" :x2="padding" :y2="v.y" stroke="#999" />
          <text :x="padding - 10" :y="v.y + 4" text-anchor="end" font-size="12" fill="#999">{{ v.value }}</text>
        </g>
        <!-- X-axis ticks and labels -->
        <g v-for="(t, i) in xTicks" :key="'x-tick-' + i">
          <line :x1="t.x" :y1="height - padding" :x2="t.x" :y2="height - padding + 5" stroke="#999" />
          <text :x="t.x" :y="height - padding + 18" text-anchor="middle" font-size="12" fill="#999">{{ t.label }}</text>
        </g>
        <!-- Data lines -->
        <g v-for="t in transformers" :key="t.assetId">
          <polyline :points="getLinePoints(t)" :stroke="getColor(t.assetId)" fill="none" stroke-width="2" />
        </g>
        <!-- Hover dot for nearest transformer only -->
        <g v-if="hoverIndex !== null && nearestTransformer">
          <circle v-if="getDotPosition(nearestTransformer, hoverIndex)"
            :cx="getDotPosition(nearestTransformer, hoverIndex)?.x"
            :cy="getDotPosition(nearestTransformer, hoverIndex)?.y" r="5" :fill="getColor(nearestTransformer.assetId)"
            stroke="#fff" stroke-width="2" />
        </g>
        <!-- X-axis -->
        <line :x1="padding" :y1="height - padding" :x2="width - padding" :y2="height - padding" stroke="#999" />
        <line :x1="padding" :y1="padding" :x2="padding" :y2="height - padding" stroke="#999" />
      </svg>
      <div class="legend">
        <span v-for="t in allTransformers" :key="t.assetId"
          :style="{ color: getColor(t.assetId), opacity: transformers.some(sel => sel.assetId === t.assetId) ? 1 : 0.3 }">
          ● {{ t.name }}
        </span>
      </div>
    </div>
    <div class="hover-info" style="margin-top: 12px;">
      <template v-if="hoverIndex !== null && nearestTransformer">
        <div class="hover-title" :style="{ color: getColor(nearestTransformer.assetId) }">
          ● {{ nearestTransformer.name }}
        </div>
        <div><strong>Asset ID:</strong> {{ nearestTransformer.assetId }}</div>
        <div><strong>Region:</strong> {{ nearestTransformer.region }}</div>
        <div><strong>Health:</strong> {{ nearestTransformer.health }}</div>
        <div>
          <strong>Voltage:</strong> {{ nearestTransformer.lastTenVoltgageReadings[hoverIndex].voltage }}
        </div>
        <div>
          <strong>Time:</strong> {{ nearestTransformer.lastTenVoltgageReadings[hoverIndex].timestamp }}
        </div>
      </template>
      <template v-else>
        <div style="color: #888;">Hover over the chart to see transformer details.</div>
      </template>
    </div>
  </div>
</template>

<script lang="ts" setup>
import type { TransformerAsset } from '../types';
import { computed, ref } from 'vue';

const props = defineProps<{
  transformers: TransformerAsset[];
  allTransformers: TransformerAsset[];
}>();

const width = 600;
const height = 300;
const padding = 50;
const colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628'];

const allVoltages = computed(() =>
  props.allTransformers.flatMap(t => t.lastTenVoltgageReadings.map(r => Number(r.voltage))).filter(v => !isNaN(v))
);
const minV = computed(() => allVoltages.value.length ? Math.min(...allVoltages.value) : 0);
const maxV = computed(() => allVoltages.value.length ? Math.max(...allVoltages.value) : 1);

const xLabels = computed(() => {
  const first = props.allTransformers[0]?.lastTenVoltgageReadings ?? [];
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

const yTicks = computed(() => {
  const ticks = 5;
  const values = [];
  const range = maxV.value - minV.value || 1;
  for (let i = 0; i < ticks; i++) {
    const value = Math.round(maxV.value - ((maxV.value - minV.value) * i) / (ticks - 1));
    const y = padding + ((maxV.value - value) / range) * (height - 2 * padding);
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
      y = padding + (height - 2 * padding) / 2;
    } else {
      y = padding + ((maxV.value - Number(r.voltage)) / range) * (height - 2 * padding);
    }
    return `${x},${y}`;
  }).join(' ');
}

// Helper to get color by transformer's index in allTransformers
function getColor(assetId: number) {
  const idx = props.allTransformers.findIndex(t => t.assetId === assetId);
  return colors[idx % colors.length];
}

// --- Hover logic ---
const hoverIndex = ref<number | null>(null);
const nearestTransformer = ref<TransformerAsset | null>(null);

const DOT_HOVER_RANGE = 18; // px, adjust for sensitivity

function onMouseMove(event: MouseEvent) {
  const rect = (event.target as SVGSVGElement).getBoundingClientRect();
  const mouseX = event.clientX - rect.left;
  const mouseY = event.clientY - rect.top;
  const count = xLabels.value.length;
  const stepX = (width - 2 * padding) / (count - 1 || 1);

  // Find closest index
  let idx = Math.round((mouseX - padding) / stepX);
  if (idx < 0) idx = 0;
  if (idx >= count) idx = count - 1;
  hoverIndex.value = idx;

  // Find the nearest transformer (by vertical distance at this index)
  let minDist = Infinity;
  let nearest: TransformerAsset | null = null;
  for (const t of props.transformers) {
    const pos = getDotPosition(t, idx);
    if (pos) {
      const dist = Math.abs(pos.y - mouseY);
      if (dist < minDist) {
        minDist = dist;
        nearest = t;
      }
    }
  }
  // Only show if within range
  nearestTransformer.value = (minDist <= DOT_HOVER_RANGE) ? nearest : null;
}

function onMouseLeave() {
  hoverIndex.value = null;
  nearestTransformer.value = null;
}

function getDotPosition(transformer: TransformerAsset, idx: number) {
  const readings = transformer.lastTenVoltgageReadings;
  if (!readings[idx]) return null;
  const stepX = (width - 2 * padding) / (readings.length - 1 || 1);
  const x = padding + idx * stepX;
  const range = maxV.value - minV.value;
  let y;
  if (range === 0) {
    y = padding + (height - 2 * padding) / 2;
  } else {
    y = padding + ((maxV.value - Number(readings[idx].voltage)) / range) * (height - 2 * padding);
  }
  return { x, y };
}
</script>

<style scoped>
.chart-container {
  display: flex;
  /* flex-direction: column; */
  align-items: center;
  position: relative;
}

.legend {
  margin-top: 10px;
  display: flex;
  gap: 16px;
  font-size: 14px;
}

.hover-info {
  /* position: absolute; */
  width: 200px;
  left: 0;
  right: 0;
  margin: 0 auto;
  top: 0;
  background: #192a3b;
  border: 1px solid #ccc;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.07);
  padding: 10px 16px;
  pointer-events: none;
  z-index: 10;
  text-align: left;
}

.hover-title {
  font-weight: bold;
  margin-bottom: 4px;
}
</style>