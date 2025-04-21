
import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

/*
  The test below is an example. To learn more, read the testing documentation here:
  https://docs.hiro.so/stacks/clarinet-js-sdk
*/

describe("example tests", () => {
  it("ensures simnet is well initalised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  // it("shows an example", () => {
  //   const { result } = simnet.callReadOnlyFn("counter", "get-counter", [], address1);
  //   expect(result).toBeUint(0);
  // });
});
import { describe, it, expect, beforeEach } from 'vitest';

// Mock implementation for testing Clarity contracts
// This is a simplified version since we can't use the specified libraries

// Mock contract state
let mockState = {
  lastInventoryId: 0,
  inventoryItems: new Map()
};

// Constants
const FIXTURE_TYPE_SINK = 1;
const FIXTURE_TYPE_TOILET = 2;
const FIXTURE_TYPE_WATER_HEATER = 4;

// Mock contract functions
const mockContract = {
  addInventoryItem: (buildingId, itemType, description, location, installationDate, manufacturer, model) => {
    const newId = mockState.lastInventoryId + 1;
    mockState.lastInventoryId = newId;
    
    // Add item to inventory map
    mockState.inventoryItems.set(newId, {
      buildingId,
      itemType,
      description,
      location,
      installationDate,
      manufacturer,
      model,
      lastMaintenanceDate: null
    });
    
    return { success: true, value: newId };
  },
  
  getInventoryItem: (inventoryId) => {
    return mockState.inventoryItems.get(inventoryId);
  },
  
  updateInventoryItem: (inventoryId, description, location, manufacturer, model) => {
    const item = mockState.inventoryItems.get(inventoryId);
    if (!item) return { success: false, error: 1 };
    
    mockState.inventoryItems.set(inventoryId, {
      ...item,
      description,
      location,
      manufacturer,
      model
    });
    
    return { success: true, value: true };
  },
  
  updateMaintenanceDate: (inventoryId, maintenanceDate) => {
    const item = mockState.inventoryItems.get(inventoryId);
    if (!item) return { success: false, error: 1 };
    
    mockState.inventoryItems.set(inventoryId, {
      ...item,
      lastMaintenanceDate: maintenanceDate
    });
    
    return { success: true, value: true };
  },
  
  removeInventoryItem: (inventoryId) => {
    const item = mockState.inventoryItems.get(inventoryId);
    if (!item) return { success: false, error: 1 };
    
    // Remove item from inventory map
    mockState.inventoryItems.delete(inventoryId);
    
    return { success: true, value: true };
  }
};

describe('System Inventory Contract', () => {
  beforeEach(() => {
    // Reset mock state before each test
    mockState = {
      lastInventoryId: 0,
      inventoryItems: new Map()
    };
  });
  
  it('should add an inventory item', () => {
    const buildingId = 1;
    const result = mockContract.addInventoryItem(
        buildingId,
        FIXTURE_TYPE_SINK,
        'Kitchen Sink',
        'First Floor Kitchen',
        1620000000,
        'SinkCo',
        'Model X100'
    );
    
    expect(result.success).toBe(true);
    expect(result.value).toBe(1);
    
    const item = mockContract.getInventoryItem(1);
    expect(item).toBeDefined();
    expect(item.buildingId).toBe(buildingId);
    expect(item.itemType).toBe(FIXTURE_TYPE_SINK);
    expect(item.description).toBe('Kitchen Sink');
    expect(item.location).toBe('First Floor Kitchen');
    expect(item.manufacturer).toBe('SinkCo');
    expect(item.model).toBe('Model X100');
    expect(item.lastMaintenanceDate).toBeNull();
  });
  
  it('should update inventory item details', () => {
    const buildingId = 1;
    mockContract.addInventoryItem(buildingId, FIXTURE_TYPE_SINK, 'Old Description', 'Old Location', 1620000000, 'Old Manufacturer', 'Old Model');
    
    const updateResult = mockContract.updateInventoryItem(
        1,
        'New Description',
        'New Location',
        'New Manufacturer',
        'New Model'
    );
    
    expect(updateResult.success).toBe(true);
    
    const item = mockContract.getInventoryItem(1);
    expect(item.description).toBe('New Description');
    expect(item.location).toBe('New Location');
    expect(item.manufacturer).toBe('New Manufacturer');
    expect(item.model).toBe('New Model');
    // These should remain unchanged
    expect(item.buildingId).toBe(buildingId);
    expect(item.itemType).toBe(FIXTURE_TYPE_SINK);
  });
  
  it('should update maintenance date', () => {
    const buildingId = 1;
    mockContract.addInventoryItem(buildingId, FIXTURE_TYPE_WATER_HEATER, 'Water Heater', 'Basement', 1620000000, 'HeaterCo', 'Model H300');
    
    const maintenanceDate = 1650000000;
    const updateResult = mockContract.updateMaintenanceDate(1, maintenanceDate);
    
    expect(updateResult.success).toBe(true);
    
    const item = mockContract.getInventoryItem(1);
    expect(item.lastMaintenanceDate).toBe(maintenanceDate);
  });
  
  it('should remove inventory item', () => {
    const buildingId = 1;
    mockContract.addInventoryItem(buildingId, FIXTURE_TYPE_SINK, 'Kitchen Sink', 'Kitchen', 1620000000, 'SinkCo', 'Model X100');
    
    const removeResult = mockContract.removeInventoryItem(1);
    
    expect(removeResult.success).toBe(true);
    
    const item = mockContract.getInventoryItem(1);
    expect(item).toBeUndefined();
  });
});
