<script lang="ts" setup>
import { ref, watch, computed, onMounted } from 'vue';
import type { TransformerAsset } from '../types';

const props = defineProps<{
  transformers: TransformerAsset[];
  loading: boolean;
  error: string | null;
}>();

const emit = defineEmits<{
  (e: 'update:selected', ids: number[]): void;
}>();

const LOCAL_STORAGE_KEY = 'transformers-data';

// Load from localStorage if available, otherwise use props
const localTransformers = ref<TransformerAsset[]>([]);

const selectedIds = ref<number[]>([]);

onMounted(() => {
  const stored = localStorage.getItem(LOCAL_STORAGE_KEY);
  if (stored) {
    try {
      localTransformers.value = JSON.parse(stored);
    } catch {
      localTransformers.value = props.transformers;
    }
  } else {
    localTransformers.value = props.transformers;
  }
});

// Ensure all checkboxes are selected by default when data loads/changes
watch(localTransformers, (val) => {
  selectedIds.value = val.map(t => t.assetId);
}, { immediate: true });

// Persist to localStorage whenever localTransformers changes
watch(localTransformers, (val) => {
  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(val));
}, { deep: true });

const search = ref('');

// Filtered transformers based on search
const filteredTransformers = computed(() => {
  if (!search.value.trim()) return localTransformers.value;
  const s = search.value.trim().toLowerCase();
  return localTransformers.value.filter(t =>
    t.name.toLowerCase().includes(s) ||
    t.region.toLowerCase().includes(s) ||
    t.health.toLowerCase().includes(s) ||
    String(t.assetId).includes(s)
  );
});

// Emit only checked IDs that are also visible in the filter
watch([selectedIds, filteredTransformers], () => {
  const visibleCheckedIds = filteredTransformers.value
    .map(t => t.assetId)
    .filter(id => selectedIds.value.includes(id));
  emit('update:selected', visibleCheckedIds);
}, { immediate: true });
</script>

<template>
  <div v-if="props.loading">Loading...</div>
  <div v-else-if="props.error">{{ props.error }}</div>
  <div v-else class="transformer-data-wrapper">
    <span>&#x1F50E;</span><input v-model="search" type="text" placeholder="Search by name, region, health, or ID"
      class="search-input" />
    <div class="transformer-list">
      <div class="table-row table-header">
        <span class="checkmark">&#x2713;</span>
        <span>Name</span>
        <span>Region</span>
        <span>Health</span>
      </div>
      <div class="table-row" v-for="t in filteredTransformers" :key="t.assetId">
        <input type="checkbox" :value="t.assetId" v-model="selectedIds" />
        <span>{{ t.name }}</span>
        <span>{{ t.region }}</span>
        <span>{{ t.health }}</span>
      </div>
      <div v-if="filteredTransformers.length === 0" class="no-results">
        No transformers match your search.
      </div>
    </div>
  </div>
</template>

<style scoped>
.transformer-data-wrapper {
  max-width: 800px;
}

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

.search-input {
  margin: 10px;
  padding: 6px 10px;
  width: 20rem;
  border-radius: 4px;
  border: 1px solid #f89953;
  font-size: 1rem;
}

.search-input:focus {
  outline: none;
  border-color: #f89953;
}

.no-results {
  color: #888;
  margin-top: 10px;
  text-align: center;
}
</style>