<script setup lang="ts">
import { ref, onMounted } from 'vue';
import TransformerData from './components/TransformerData.vue';
import VoltageLineChart from './components/VoltageLineChart.vue';
import type { TransformerAsset } from './types';

const transformers = ref<TransformerAsset[]>([]);
const loading = ref(true);
const error = ref<string | null>(null);

onMounted(async () => {
  try {
    const response = await fetch('/sampledata.json');
    if (!response.ok) throw new Error('Failed to fetch data');
    const data = await response.json();
    transformers.value = data as TransformerAsset[];
  } catch (err: any) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
});
</script>

<template>
  <div id="app">
    <h1>Transformers Data</h1>
    <TransformerData :transformers="transformers" :loading="loading" :error="error" />
    <VoltageLineChart :transformers="transformers" />
  </div>
</template>

<style>
/* Add your styles here if needed */
</style>
