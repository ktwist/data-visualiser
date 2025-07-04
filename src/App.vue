<template>
    <h1 class="app-title">Transformers Data</h1>
    <div v-if="loading" class="loader">Loading data...</div>
    <TransformerData
      v-else
      :transformers="transformers"
      :loading="loading"
      :error="error"
      @update:selected="selectedIds = $event"
    />
    <VoltageLineChart
      v-if="!loading && !error"
      :transformers="selectedTransformers"
      :all-transformers="transformers"
    />
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import TransformerData from './components/TransformerData.vue';
import VoltageLineChart from './components/VoltageLineChart.vue';
import type { TransformerAsset } from './types';

const transformers = ref<TransformerAsset[]>([]);
const loading = ref(true);
const error = ref<string | null>(null);
const selectedIds = ref<number[]>([]);

const selectedTransformers = computed(() =>
  transformers.value.filter(t => selectedIds.value.includes(t.assetId))
);

// Helper to simulate delay
function delay(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

onMounted(async () => {
  try {
    const response = await fetch('/sampledata.json');
    if (!response.ok) throw new Error('Failed to fetch data');
    // Simulate long API response (e.g., 2 seconds)
    await delay(2000);
    const data = await response.json();

    // Sort each transformer's readings by timestamp (chronological order)
    data.forEach((t: TransformerAsset) => {
      t.lastTenVoltgageReadings.sort(
        (a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
      );
    });

    transformers.value = data as TransformerAsset[];
  } catch (err: any) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
});
</script>

<style>
.app-title {
  text-align: center;
  padding: 1rem;
  font-size: 2rem;
  color: #f8a553;
  border-bottom: #f8a553 2px solid;
}
.loader {
  margin: 2rem 0;
  font-size: 1.2rem;
  color: #377eb8;
  text-align: center;
}
</style>
