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
  <div v-else class="transformer-list">
    <div class="table-row table-header"><span
        class="checkmark">&#x2713;</span><span>Name</span><span>Region</span><span>Health</span></div>
    <div class="table-row" v-for="t in props.transformers" :key="t.assetId">
      <input type="checkbox" :value="t.assetId" v-model="selectedIds" />
      <span>{{ t.name }}</span> <span>{{ t.region }}</span> <span>{{ t.health }}</span>
    </div>
  </div>
</template>

<style scoped>
.transformer-list {
  display: grid;
  grid-template-columns: 1fr;
  grid-template-rows: auto;
  overflow-y: auto;
  border: 2px solid #f89953;
}

.checkmark {
  text-align: center;
}

.table-row.table-header {
  color: #353637;
  background-color: #f89953;
  border-bottom: 2px solid #f89953;
}

.table-header span {
  font-weight: bold;
}

.table-row {
  display: grid;
  grid-template-columns: 0.3fr 2fr 2fr 2fr;
  grid-template-rows: subgrid;
  justify-content: start;
  border-bottom: 1px solid #f89953;
}

.transformer-list>.table-row:last-child {
  border-bottom: 0px none;
}

.table-row span {
  padding: 5px 0 5px 10px;
  border-right: 1px solid #f89953;
}
</style>