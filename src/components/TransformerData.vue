<script lang="ts" setup>
import type { TransformerAsset } from '../types';

const props = defineProps<{
  transformers: TransformerAsset[];
  loading: boolean;
  error: string | null;
}>();
</script>

<template>
  <div v-if="props.loading">Loading...</div>
  <div v-else-if="props.error">{{ props.error }}</div>
  <div v-else>
    <ul>
      <li v-for="t in props.transformers" :key="t.assetId">
        {{ t.name }} ({{ t.region }}) - Health: {{ t.health }}
      </li>
    </ul>
  </div>
</template>