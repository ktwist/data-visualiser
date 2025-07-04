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
    <div class="table-row"><span>&#x2713;</span><span>Name</span><span>Region</span><span>Health</span></div>
      <div class="table-row" v-for="t in props.transformers" :key="t.assetId">
          <input
            type="checkbox"
            :value="t.assetId"
            v-model="selectedIds"
          />
          <span>{{ t.name }}</span> <span>{{ t.region }}</span> <span>{{ t.health }}</span>
      </div>
  </div>
</template>

<style scoped>
.transformer-list {
  max-height: 400px;
  overflow-y: auto;
  border: 1px solid #ccc;
}
.table-row {
  display: flex;
  font-weight: bold;
  justify-content: space-between;
  border-bottom: 1px solid #eee;

}
.table-row :first-child {
  flex-grow: 0.5;
}
.table-row span {
  flex-grow: 2;
  padding: 5px 0;
}
</style>