<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import type { TransformerAsset } from '../types';

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
  <div v-if="loading">Loading...</div>
  <div v-else-if="error">{{ error }}</div>
  <div v-else>
    <ul>
      <li v-for="t in transformers" :key="t.assetId">
        {{ t.name }} ({{ t.region }}) - Health: {{ t.health }}
      </li>
    </ul>
  </div>
</template>