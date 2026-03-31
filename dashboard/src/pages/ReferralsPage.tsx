import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { referralsApi, Referral } from '../services/api'
import { useAuthStore } from '../stores/authStore'
import {
  Clock,
  CheckCircle,
  XCircle,
  AlertCircle,
  Phone,
  MapPin,
  User,
  Calendar,
} from 'lucide-react'

const STATUS_CONFIG = {
  pending: { label: 'Pending', icon: Clock, color: 'text-yellow-600', bg: 'bg-yellow-100' },
  in_transit: { label: 'In Transit', icon: AlertCircle, color: 'text-blue-600', bg: 'bg-blue-100' },
  arrived: { label: 'Arrived', icon: CheckCircle, color: 'text-green-600', bg: 'bg-green-100' },
  completed: { label: 'Completed', icon: CheckCircle, color: 'text-gray-600', bg: 'bg-gray-100' },
  cancelled: { label: 'Cancelled', icon: XCircle, color: 'text-red-600', bg: 'bg-red-100' },
}

export default function ReferralsPage() {
  const [status, setStatus] = useState<string>('')
  const [urgencyFilter, setUrgencyFilter] = useState<string>('')
  const user = useAuthStore((state) => state.user)
  const queryClient = useQueryClient()

  const { data, isLoading } = useQuery({
    queryKey: ['referrals', { status, urgency: urgencyFilter, facilityId: user?.facilityId }],
    queryFn: () => referralsApi.list({
      status: status || undefined,
      urgency: urgencyFilter || undefined,
      facilityId: user?.facilityId,
      limit: 100,
    }),
    refetchInterval: 30000, // Refresh every 30 seconds
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      referralsApi.updateStatus(id, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['referrals'] })
    },
  })

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Referrals</h1>
        <p className="text-gray-500 mt-1">
          Track and manage patient referrals
        </p>
      </div>

      {/* Status tabs */}
      <div className="flex gap-2 overflow-x-auto pb-2">
        <button
          onClick={() => setStatus('')}
          className={`px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap ${
            status === ''
              ? 'bg-primary-100 text-primary-700'
              : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
          }`}
        >
          All ({data?.length || 0})
        </button>
        {Object.entries(STATUS_CONFIG).map(([key, config]) => (
          <button
            key={key}
            onClick={() => setStatus(key)}
            className={`px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap flex items-center gap-2 ${
              status === key
                ? 'bg-primary-100 text-primary-700'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            <config.icon size={16} />
            {config.label}
          </button>
        ))}
      </div>

      {/* Urgency filter */}
      <div className="flex gap-2">
        <select
          value={urgencyFilter}
          onChange={(e) => setUrgencyFilter(e.target.value)}
          className="px-4 py-2 border border-gray-200 rounded-lg text-sm"
        >
          <option value="">All Urgency</option>
          <option value="emergency">Emergency</option>
          <option value="urgent">Urgent</option>
          <option value="routine">Routine</option>
        </select>
      </div>

      {/* Referral list */}
      {isLoading ? (
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600" />
        </div>
      ) : (
        <div className="grid gap-4">
          {data?.map((referral: Referral) => (
            <ReferralCard
              key={referral.id}
              referral={referral}
              onUpdateStatus={(newStatus) =>
                updateMutation.mutate({ id: referral.id, status: newStatus })
              }
              isUpdating={updateMutation.isPending}
            />
          ))}
          {data?.length === 0 && (
            <div className="card text-center py-12 text-gray-500">
              No referrals found
            </div>
          )}
        </div>
      )}
    </div>
  )
}

interface ReferralCardProps {
  referral: Referral
  onUpdateStatus: (status: string) => void
  isUpdating: boolean
}

function ReferralCard({ referral, onUpdateStatus, isUpdating }: ReferralCardProps) {
  const statusConfig = STATUS_CONFIG[referral.status as keyof typeof STATUS_CONFIG]
  const StatusIcon = statusConfig?.icon || Clock

  const urgencyColors = {
    emergency: 'border-l-red-500 bg-red-50',
    urgent: 'border-l-orange-500 bg-orange-50',
    routine: 'border-l-blue-500 bg-blue-50',
  }

  return (
    <div
      className={`card border-l-4 ${
        urgencyColors[referral.urgency as keyof typeof urgencyColors] || ''
      }`}
    >
      <div className="flex flex-col lg:flex-row lg:items-start justify-between gap-4">
        {/* Patient info */}
        <div className="flex-1 space-y-3">
          <div className="flex items-start justify-between">
            <div>
              <h3 className="font-semibold text-gray-900 flex items-center gap-2">
                <User size={18} />
                {referral.patientName || 'Unknown Patient'}
              </h3>
              <p className="text-sm text-gray-500">
                Referral #{referral.id.slice(0, 8)}
              </p>
            </div>
            <span
              className={`px-3 py-1 rounded-full text-xs font-semibold uppercase ${
                referral.urgency === 'emergency'
                  ? 'bg-red-100 text-red-700'
                  : referral.urgency === 'urgent'
                  ? 'bg-orange-100 text-orange-700'
                  : 'bg-blue-100 text-blue-700'
              }`}
            >
              {referral.urgency}
            </span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm">
            <div className="flex items-center gap-2 text-gray-600">
              <MapPin size={16} />
              <span>
                {referral.fromFacilityName || 'Unknown'} → {referral.toFacilityName || 'Unknown'}
              </span>
            </div>
            <div className="flex items-center gap-2 text-gray-600">
              <Calendar size={16} />
              <span>{new Date(referral.createdAt).toLocaleString()}</span>
            </div>
            {referral.contactPhone && (
              <div className="flex items-center gap-2 text-gray-600">
                <Phone size={16} />
                <span>{referral.contactPhone}</span>
              </div>
            )}
          </div>

          {referral.reason && (
            <p className="text-sm text-gray-700 bg-white p-3 rounded border">
              <strong>Reason:</strong> {referral.reason}
            </p>
          )}
        </div>

        {/* Status and actions */}
        <div className="flex flex-col items-end gap-3">
          <div className={`flex items-center gap-2 px-3 py-2 rounded-lg ${statusConfig?.bg}`}>
            <StatusIcon size={18} className={statusConfig?.color} />
            <span className={`font-medium ${statusConfig?.color}`}>{statusConfig?.label}</span>
          </div>

          {/* Status update buttons */}
          {referral.status !== 'completed' && referral.status !== 'cancelled' && (
            <div className="flex gap-2">
              {referral.status === 'pending' && (
                <button
                  onClick={() => onUpdateStatus('in_transit')}
                  disabled={isUpdating}
                  className="btn-primary text-sm py-1"
                >
                  Mark In Transit
                </button>
              )}
              {referral.status === 'in_transit' && (
                <button
                  onClick={() => onUpdateStatus('arrived')}
                  disabled={isUpdating}
                  className="btn-primary text-sm py-1"
                >
                  Mark Arrived
                </button>
              )}
              {referral.status === 'arrived' && (
                <button
                  onClick={() => onUpdateStatus('completed')}
                  disabled={isUpdating}
                  className="btn-primary text-sm py-1"
                >
                  Complete
                </button>
              )}
              <button
                onClick={() => onUpdateStatus('cancelled')}
                disabled={isUpdating}
                className="btn-secondary text-sm py-1 text-red-600 hover:bg-red-50"
              >
                Cancel
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
