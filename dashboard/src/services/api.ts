import axios from 'axios'
import { useAuthStore } from '../stores/authStore'

const api = axios.create({
  baseURL: '/api',
  timeout: 30000,
})

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// Handle auth errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      useAuthStore.getState().logout()
    }
    return Promise.reject(error)
  }
)

// Auth
export const authApi = {
  login: async (phone: string, pin: string) => {
    const { data } = await api.post('/auth/login', { phone, pin })
    return data
  },
}

// Dashboard
export const dashboardApi = {
  getOverview: async (regionId?: string) => {
    const { data } = await api.get('/dashboard/overview', { params: { regionId } })
    return data
  },
  
  getRiskDistribution: async (regionId?: string) => {
    const { data } = await api.get('/dashboard/risk-distribution', { params: { regionId } })
    return data
  },
  
  getReferralsByDay: async (regionId?: string, days = 30) => {
    const { data } = await api.get('/dashboard/referrals-by-day', { params: { regionId, days } })
    return data
  },
  
  getTopFactors: async (regionId?: string) => {
    const { data } = await api.get('/dashboard/top-factors', { params: { regionId } })
    return data
  },
  
  getRegionalComparison: async () => {
    const { data } = await api.get('/dashboard/regional-comparison')
    return data
  },
  
  getAnalytics: async (params: { timeRange?: string; regionId?: string }) => {
    const { data } = await api.get('/dashboard/analytics', { params })
    return data
  },
  
  getRegions: async () => {
    const { data } = await api.get('/dashboard/regions')
    return data
  },
  
  getMapData: async (regionId?: string) => {
    const { data } = await api.get('/dashboard/map-data', { params: { regionId } })
    return data
  },
}

// Patients
export interface Patient {
  id: string
  fullName: string
  age: number
  gravida: number
  parity: number
  isPregnant: boolean
  gestationalWeeks?: number
  latestRiskScore?: number
  latestRiskTier?: 'low' | 'medium' | 'high'
  facilityName?: string
  regionName?: string
}

export const patientsApi = {
  list: async (params: { 
    limit?: number
    offset?: number
    pregnantOnly?: boolean
    highRiskOnly?: boolean
    regionId?: string
  }) => {
    const { data } = await api.get('/patients', { params })
    return data as { patients: Patient[]; count: number }
  },
  
  getById: async (id: string) => {
    const { data } = await api.get(`/patients/${id}`)
    return data
  },
}

// Referrals
export interface Referral {
  id: string
  patientId: string
  patientName: string
  triggerType: string
  triggerDetail: Record<string, unknown>
  aiRiskScore?: number
  status: 'pending' | 'acknowledged' | 'in_transit' | 'arrived' | 'completed' | 'cancelled'
  urgency: 'routine' | 'urgent' | 'emergency'
  reason?: string
  fromFacilityId?: string
  fromFacilityName?: string
  toFacilityId?: string
  toFacilityName?: string
  contactPhone?: string
  createdAt: string
  acknowledgedAt?: string
  arrivedAt?: string
}

export const referralsApi = {
  list: async (params: {
    status?: string
    urgency?: string
    regionId?: string
    facilityId?: string
    limit?: number
  }) => {
    const { data } = await api.get('/referrals', { params })
    return data as Referral[]
  },
  
  updateStatus: async (id: string, status: string) => {
    const { data } = await api.patch(`/referrals/${id}/status`, { status })
    return data
  },
}

// Facilities
export interface Facility {
  id: string
  name: string
  level: string
  facilityType?: string
  address?: string
  phone?: string
  latitude?: number
  longitude?: number
  regionId?: string
  regionName?: string
  patientCount?: number
  referralCount?: number
  bedCount?: number
  hasEmoc?: boolean
  hasBloodBank?: boolean
  occupancy?: number
}

export const facilitiesApi = {
  list: async (params?: { regionId?: string; level?: string }) => {
    const { data } = await api.get('/facilities', { params })
    return data as Facility[]
  },
  
  getById: async (id: string) => {
    const { data } = await api.get(`/facilities/${id}`)
    return data as Facility
  },
  
  create: async (facility: Partial<Facility>) => {
    const { data } = await api.post('/facilities', facility)
    return data as Facility
  },
  
  update: async (id: string, facility: Partial<Facility>) => {
    const { data } = await api.patch(`/facilities/${id}`, facility)
    return data as Facility
  },
  
  getRegions: async () => {
    const { data } = await api.get('/regions')
    return data
  },
}

// Map data
export const mapApi = {
  getPatientLocations: async (regionId?: string) => {
    const { data } = await api.get('/dashboard/map/patients', { params: { regionId } })
    return data
  },
  
  getFacilityLocations: async (regionId?: string) => {
    const { data } = await api.get('/dashboard/map/facilities', { params: { regionId } })
    return data
  },
}

export default api
