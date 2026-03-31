-- Device Registry Migration
-- Associates monitoring devices with patients for automatic data linking

-- Device registry table
CREATE TABLE IF NOT EXISTS devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id VARCHAR(100) NOT NULL UNIQUE, -- BLE MAC address or serial number
    device_type VARCHAR(50) NOT NULL, -- 'bp_cuff', 'oximeter', 'thermometer', 'fetal_doppler', 'wearfit'
    device_name VARCHAR(200), -- Human-readable name e.g., "BP Cuff #12"
    device_model VARCHAR(100), -- e.g., "iHealth KN-550BT"
    
    -- Current assignment
    assigned_patient_id UUID REFERENCES patients(id),
    assigned_at TIMESTAMPTZ,
    assigned_by UUID REFERENCES users(id),
    
    -- Ownership
    facility_id UUID REFERENCES facilities(id),
    region_id UUID REFERENCES regions(id),
    
    -- Status
    status VARCHAR(30) DEFAULT 'available', -- 'available', 'assigned', 'maintenance', 'lost'
    battery_level INT, -- 0-100
    last_seen_at TIMESTAMPTZ,
    firmware_version VARCHAR(50),
    
    -- Metadata
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_devices_patient ON devices(assigned_patient_id) WHERE assigned_patient_id IS NOT NULL;
CREATE INDEX idx_devices_facility ON devices(facility_id);
CREATE INDEX idx_devices_device_id ON devices(device_id);
CREATE INDEX idx_devices_status ON devices(status);

-- Device assignment history (audit trail)
CREATE TABLE IF NOT EXISTS device_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES devices(id),
    patient_id UUID NOT NULL REFERENCES patients(id),
    assigned_by UUID NOT NULL REFERENCES users(id),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    unassigned_at TIMESTAMPTZ,
    unassigned_by UUID REFERENCES users(id),
    reason VARCHAR(100) -- 'delivery_complete', 'device_issue', 'patient_transfer', etc.
);

CREATE INDEX idx_device_assignments_device ON device_assignments(device_id);
CREATE INDEX idx_device_assignments_patient ON device_assignments(patient_id);

-- Update trigger for devices
CREATE TRIGGER tr_devices_updated_at
    BEFORE UPDATE ON devices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Function to get patient by device ID
CREATE OR REPLACE FUNCTION get_patient_by_device(p_device_id VARCHAR)
RETURNS UUID AS $$
DECLARE
    v_patient_id UUID;
BEGIN
    SELECT assigned_patient_id INTO v_patient_id
    FROM devices
    WHERE device_id = p_device_id
      AND status = 'assigned'
      AND assigned_patient_id IS NOT NULL;
    
    RETURN v_patient_id;
END;
$$ LANGUAGE plpgsql;

-- Add device_id column to readings for direct tracking
ALTER TABLE readings ADD COLUMN IF NOT EXISTS device_hardware_id VARCHAR(100);
CREATE INDEX IF NOT EXISTS idx_readings_device_hw ON readings(device_hardware_id);
