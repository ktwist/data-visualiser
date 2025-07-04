<script lang="ts" setup>
import { ref, watch, defineEmits } from 'vue';
import type { TransformerAsset } from '../types';

const props = defineProps<{
  transformers: TransformerAsset[];
  loading: boolean;
  error: string | null;
}>();

const emit = defineEmits<{
  (e: 'update:selected', ids: number[]): void;
}>();

// Track checked transformer IDs
const selectedIds = ref<number[]>(props.transformers.map(t => t.assetId));

// Emit on change
watch(selectedIds, (val) => emit('update:selected', val), { immediate: true });

</script>

<template>
  <div v-if="props.loading">Loading...</div>
  <div v-else-if="props.error">{{ props.error }}</div>
  <div v-else>
    <ul>
      <li v-for="t in props.transformers" :key="t.assetId">
        <label>
          <input
            type="checkbox"
            :value="t.assetId"
            v-model="selectedIds"
          />
          {{ t.name }} ({{ t.region }}) - Health: {{ t.health }}
        </label>
      </li>
    </ul>
  </div>
</template>