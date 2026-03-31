import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { facilitiesApi, Facility } from '../services/api'
import {
  Building2, MapPin, Phone, Users, Bed, Plus,
  Edit, Check, X, AlertCircle, Search
} from 'lucide-react'

export default function FacilitiesPage() {
  const [search, setSearch] = useState('')
  const [levelFilter, setLevelFilter] = useState('')
  const [editingId, setEditingId] = useState<string | null>(null)
  const [showAddModal, setShowAddModal] = useState(false)

  const queryClient = useQueryClient()

  const { data: facilities, isLoading } = useQuery({
    queryKey: ['facilities', levelFilter],
    queryFn: () => facilitiesApi.list({ level: levelFilter || undefined }),
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<Facility> }) =>
      facilitiesApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['facilities'] })
      setEditingId(null)
    },
  })

  const filteredFacilities = facilities?.filter((f: Facility) =>
    f.name.toLowerCase().includes(search.toLowerCase()) ||
    f.regionName?.toLowerCase().includes(search.toLowerCase())
  ) || []

  // Group by level
  const levels = ['Health Center II', 'Health Center III', 'Health Center IV', 'District Hospital', 'Regional Hospital']

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Facilities</h1>
          <p className="text-gray-500 mt-1">
            {facilities?.length || 0} health facilities
          </p>
        </div>

        <button
          onClick={() => setShowAddModal(true)}
          className="btn-primary flex items-center gap-2"
        >
          <Plus size={18} />
          Add Facility
        </button>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
            <input
              type="text"
              placeholder="Search facilities..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
            />
          </div>

          <select
            value={levelFilter}
            onChange={(e) => setLevelFilter(e.target.value)}
            className="px-4 py-2 border border-gray-200 rounded-lg text-sm"
          >
            <option value="">All Levels</option>
            {levels.map((level) => (
              <option key={level} value={level}>{level}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Facilities Grid */}
      {isLoading ? (
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600" />
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredFacilities.map((facility: Facility) => (
            <FacilityCard
              key={facility.id}
              facility={facility}
              isEditing={editingId === facility.id}
              onEdit={() => setEditingId(facility.id)}
              onCancel={() => setEditingId(null)}
              onSave={(data) => updateMutation.mutate({ id: facility.id, data })}
              isSaving={updateMutation.isPending}
            />
          ))}
          {filteredFacilities.length === 0 && (
            <div className="col-span-full text-center py-12 text-gray-500">
              No facilities found
            </div>
          )}
        </div>
      )}

      {/* Add Facility Modal */}
      {showAddModal && (
        <AddFacilityModal onClose={() => setShowAddModal(false)} />
      )}
    </div>
  )
}

interface FacilityCardProps {
  facility: Facility
  isEditing: boolean
  onEdit: () => void
  onCancel: () => void
  onSave: (data: Partial<Facility>) => void
  isSaving: boolean
}

function FacilityCard({ facility, isEditing, onEdit, onCancel, onSave, isSaving }: FacilityCardProps) {
  const [editData, setEditData] = useState({
    bedCount: facility.bedCount || 0,
    hasEmoc: facility.hasEmoc || false,
    hasBloodBank: facility.hasBloodBank || false,
    phone: facility.phone || '',
  })

  const levelColors: Record<string, string> = {
    'Health Center II': 'bg-gray-100 text-gray-700',
    'Health Center III': 'bg-blue-100 text-blue-700',
    'Health Center IV': 'bg-purple-100 text-purple-700',
    'District Hospital': 'bg-orange-100 text-orange-700',
    'Regional Hospital': 'bg-red-100 text-red-700',
  }

  return (
    <div className="card hover:shadow-md transition-shadow">
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center">
            <Building2 className="text-primary-600" size={20} />
          </div>
          <div>
            <h3 className="font-semibold text-gray-900">{facility.name}</h3>
            <span className={`inline-block text-xs px-2 py-0.5 rounded-full ${levelColors[facility.level] || 'bg-gray-100'}`}>
              {facility.level}
            </span>
          </div>
        </div>

        {!isEditing && (
          <button
            onClick={onEdit}
            className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded"
          >
            <Edit size={16} />
          </button>
        )}
      </div>

      {isEditing ? (
        <div className="space-y-3">
          <div>
            <label className="text-xs text-gray-500">Bed Count</label>
            <input
              type="number"
              value={editData.bedCount}
              onChange={(e) => setEditData({ ...editData, bedCount: parseInt(e.target.value) || 0 })}
              className="w-full mt-1 px-3 py-2 border rounded text-sm"
            />
          </div>
          <div>
            <label className="text-xs text-gray-500">Phone</label>
            <input
              type="tel"
              value={editData.phone}
              onChange={(e) => setEditData({ ...editData, phone: e.target.value })}
              className="w-full mt-1 px-3 py-2 border rounded text-sm"
            />
          </div>
          <div className="flex gap-4">
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={editData.hasEmoc}
                onChange={(e) => setEditData({ ...editData, hasEmoc: e.target.checked })}
              />
              EmOC Available
            </label>
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={editData.hasBloodBank}
                onChange={(e) => setEditData({ ...editData, hasBloodBank: e.target.checked })}
              />
              Blood Bank
            </label>
          </div>
          <div className="flex gap-2 pt-2">
            <button
              onClick={() => onSave(editData)}
              disabled={isSaving}
              className="btn-primary text-sm py-1 flex items-center gap-1"
            >
              <Check size={14} /> Save
            </button>
            <button
              onClick={onCancel}
              disabled={isSaving}
              className="btn-secondary text-sm py-1 flex items-center gap-1"
            >
              <X size={14} /> Cancel
            </button>
          </div>
        </div>
      ) : (
        <div className="space-y-2 text-sm">
          {facility.regionName && (
            <div className="flex items-center gap-2 text-gray-600">
              <MapPin size={14} />
              {facility.regionName}
            </div>
          )}
          {facility.phone && (
            <div className="flex items-center gap-2 text-gray-600">
              <Phone size={14} />
              {facility.phone}
            </div>
          )}
          <div className="flex items-center gap-2 text-gray-600">
            <Bed size={14} />
            {facility.bedCount || 0} beds
          </div>

          <div className="flex flex-wrap gap-2 pt-2">
            {facility.hasEmoc && (
              <span className="px-2 py-1 bg-green-100 text-green-700 text-xs rounded-full">
                EmOC ✓
              </span>
            )}
            {facility.hasBloodBank && (
              <span className="px-2 py-1 bg-red-100 text-red-700 text-xs rounded-full">
                Blood Bank ✓
              </span>
            )}
            {!facility.hasEmoc && !facility.hasBloodBank && (
              <span className="px-2 py-1 bg-gray-100 text-gray-500 text-xs rounded-full">
                Basic services
              </span>
            )}
          </div>

          {/* Capacity indicator */}
          {facility.bedCount !== undefined && facility.bedCount > 0 && (
            <div className="pt-2">
              <div className="flex justify-between text-xs text-gray-500 mb-1">
                <span>Occupancy</span>
                <span>{facility.occupancy || 0}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div
                  className={`h-2 rounded-full ${
                    (facility.occupancy || 0) > 90
                      ? 'bg-red-500'
                      : (facility.occupancy || 0) > 70
                      ? 'bg-yellow-500'
                      : 'bg-green-500'
                  }`}
                  style={{ width: `${Math.min(100, facility.occupancy || 0)}%` }}
                />
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  )
}

function AddFacilityModal({ onClose }: { onClose: () => void }) {
  const [form, setForm] = useState({
    name: '',
    level: 'Health Center III',
    regionId: '',
    latitude: '',
    longitude: '',
    phone: '',
    bedCount: '',
    hasEmoc: false,
    hasBloodBank: false,
  })

  const queryClient = useQueryClient()

  const createMutation = useMutation({
    mutationFn: (data: typeof form) => facilitiesApi.create({
      ...data,
      latitude: parseFloat(data.latitude) || undefined,
      longitude: parseFloat(data.longitude) || undefined,
      bedCount: parseInt(data.bedCount) || undefined,
    }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['facilities'] })
      onClose()
    },
  })

  const { data: regions } = useQuery({
    queryKey: ['regions'],
    queryFn: () => facilitiesApi.getRegions(),
  })

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl shadow-xl w-full max-w-md mx-4 p-6">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Add New Facility</h2>

        <form
          onSubmit={(e) => {
            e.preventDefault()
            createMutation.mutate(form)
          }}
          className="space-y-4"
        >
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Facility Name *
            </label>
            <input
              type="text"
              required
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
              className="w-full px-3 py-2 border rounded-lg"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Level *
              </label>
              <select
                value={form.level}
                onChange={(e) => setForm({ ...form, level: e.target.value })}
                className="w-full px-3 py-2 border rounded-lg"
              >
                <option value="Health Center II">Health Center II</option>
                <option value="Health Center III">Health Center III</option>
                <option value="Health Center IV">Health Center IV</option>
                <option value="District Hospital">District Hospital</option>
                <option value="Regional Hospital">Regional Hospital</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Region
              </label>
              <select
                value={form.regionId}
                onChange={(e) => setForm({ ...form, regionId: e.target.value })}
                className="w-full px-3 py-2 border rounded-lg"
              >
                <option value="">Select region</option>
                {regions?.map((region: any) => (
                  <option key={region.id} value={region.id}>
                    {region.name}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Latitude
              </label>
              <input
                type="text"
                value={form.latitude}
                onChange={(e) => setForm({ ...form, latitude: e.target.value })}
                placeholder="e.g. 0.3476"
                className="w-full px-3 py-2 border rounded-lg"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Longitude
              </label>
              <input
                type="text"
                value={form.longitude}
                onChange={(e) => setForm({ ...form, longitude: e.target.value })}
                placeholder="e.g. 32.5825"
                className="w-full px-3 py-2 border rounded-lg"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Phone
              </label>
              <input
                type="tel"
                value={form.phone}
                onChange={(e) => setForm({ ...form, phone: e.target.value })}
                className="w-full px-3 py-2 border rounded-lg"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Bed Count
              </label>
              <input
                type="number"
                value={form.bedCount}
                onChange={(e) => setForm({ ...form, bedCount: e.target.value })}
                className="w-full px-3 py-2 border rounded-lg"
              />
            </div>
          </div>

          <div className="flex gap-4">
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={form.hasEmoc}
                onChange={(e) => setForm({ ...form, hasEmoc: e.target.checked })}
              />
              <span className="text-sm">EmOC Available</span>
            </label>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={form.hasBloodBank}
                onChange={(e) => setForm({ ...form, hasBloodBank: e.target.checked })}
              />
              <span className="text-sm">Blood Bank</span>
            </label>
          </div>

          {createMutation.isError && (
            <div className="flex items-center gap-2 text-red-600 text-sm">
              <AlertCircle size={16} />
              Failed to create facility
            </div>
          )}

          <div className="flex gap-3 pt-2">
            <button
              type="submit"
              disabled={createMutation.isPending}
              className="btn-primary flex-1"
            >
              {createMutation.isPending ? 'Creating...' : 'Create Facility'}
            </button>
            <button
              type="button"
              onClick={onClose}
              className="btn-secondary"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
