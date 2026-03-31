import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { patientsApi, Patient } from '../services/api'
import { useAuthStore } from '../stores/authStore'
import { Search, Filter, ChevronDown, AlertTriangle } from 'lucide-react'

export default function PatientsPage() {
  const [search, setSearch] = useState('')
  const [highRiskOnly, setHighRiskOnly] = useState(false)
  const [pregnantOnly, setPregnantOnly] = useState(true)
  const [page, setPage] = useState(0)
  const limit = 20

  const user = useAuthStore((state) => state.user)

  const { data, isLoading } = useQuery({
    queryKey: ['patients', { highRiskOnly, pregnantOnly, page, regionId: user?.regionId }],
    queryFn: () => patientsApi.list({
      highRiskOnly,
      pregnantOnly,
      limit,
      offset: page * limit,
      regionId: user?.regionId,
    }),
  })

  const filteredPatients = data?.patients.filter(
    (p) => p.fullName.toLowerCase().includes(search.toLowerCase())
  ) || []

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Patients</h1>
          <p className="text-gray-500 mt-1">
            {data?.count || 0} patients total
          </p>
        </div>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="flex flex-col md:flex-row gap-4">
          {/* Search */}
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
            <input
              type="text"
              placeholder="Search patients..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
            />
          </div>

          {/* Filter toggles */}
          <div className="flex gap-3">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={pregnantOnly}
                onChange={(e) => setPregnantOnly(e.target.checked)}
                className="rounded"
              />
              <span className="text-sm">Pregnant only</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={highRiskOnly}
                onChange={(e) => setHighRiskOnly(e.target.checked)}
                className="rounded"
              />
              <span className="text-sm text-red-600 font-medium">High risk only</span>
            </label>
          </div>
        </div>
      </div>

      {/* Patient list */}
      {isLoading ? (
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600" />
        </div>
      ) : (
        <div className="card overflow-hidden p-0">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                <th className="text-left px-6 py-4 text-sm font-medium text-gray-500">Patient</th>
                <th className="text-left px-6 py-4 text-sm font-medium text-gray-500">Age</th>
                <th className="text-left px-6 py-4 text-sm font-medium text-gray-500">Gravida/Parity</th>
                <th className="text-left px-6 py-4 text-sm font-medium text-gray-500">Gestational Age</th>
                <th className="text-left px-6 py-4 text-sm font-medium text-gray-500">Risk</th>
                <th className="text-left px-6 py-4 text-sm font-medium text-gray-500">Facility</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filteredPatients.map((patient) => (
                <PatientRow key={patient.id} patient={patient} />
              ))}
              {filteredPatients.length === 0 && (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-gray-500">
                    No patients found
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* Pagination */}
      {data && data.count > limit && (
        <div className="flex justify-center gap-2">
          <button
            onClick={() => setPage((p) => Math.max(0, p - 1))}
            disabled={page === 0}
            className="btn-secondary disabled:opacity-50"
          >
            Previous
          </button>
          <span className="px-4 py-2 text-sm text-gray-600">
            Page {page + 1} of {Math.ceil(data.count / limit)}
          </span>
          <button
            onClick={() => setPage((p) => p + 1)}
            disabled={(page + 1) * limit >= data.count}
            className="btn-secondary disabled:opacity-50"
          >
            Next
          </button>
        </div>
      )}
    </div>
  )
}

function PatientRow({ patient }: { patient: Patient }) {
  return (
    <tr className="hover:bg-gray-50 cursor-pointer">
      <td className="px-6 py-4">
        <div className="flex items-center gap-3">
          <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
            patient.latestRiskTier === 'high'
              ? 'bg-red-100 text-red-600'
              : patient.latestRiskTier === 'medium'
              ? 'bg-orange-100 text-orange-600'
              : 'bg-green-100 text-green-600'
          }`}>
            {patient.latestRiskTier === 'high' ? (
              <AlertTriangle size={18} />
            ) : (
              patient.fullName.charAt(0)
            )}
          </div>
          <div>
            <p className="font-medium text-gray-900">{patient.fullName}</p>
            {patient.regionName && (
              <p className="text-sm text-gray-500">{patient.regionName}</p>
            )}
          </div>
        </div>
      </td>
      <td className="px-6 py-4 text-gray-600">{patient.age || '-'}</td>
      <td className="px-6 py-4 text-gray-600">
        G{patient.gravida}P{patient.parity}
      </td>
      <td className="px-6 py-4 text-gray-600">
        {patient.gestationalWeeks ? `${patient.gestationalWeeks} weeks` : '-'}
      </td>
      <td className="px-6 py-4">
        <RiskBadge tier={patient.latestRiskTier} score={patient.latestRiskScore} />
      </td>
      <td className="px-6 py-4 text-gray-600">{patient.facilityName || '-'}</td>
    </tr>
  )
}

function RiskBadge({ tier, score }: { tier?: string; score?: number }) {
  if (!tier) return <span className="text-gray-400">-</span>

  const classes = {
    high: 'risk-badge risk-high',
    medium: 'risk-badge risk-medium',
    low: 'risk-badge risk-low',
  }

  return (
    <span className={classes[tier as keyof typeof classes] || 'risk-badge'}>
      {tier.toUpperCase()}
      {score !== undefined && ` (${Math.round(score * 100)}%)`}
    </span>
  )
}
