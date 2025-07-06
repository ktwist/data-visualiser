export interface VoltageReading {
  timestamp: string;
  voltage: string;
}

export interface TransformerAsset {
  assetId: number;
  name: string;
  region: string;
  health: string;
  lastTenVoltgageReadings: VoltageReading[];
}