import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  LineChart, Line, AreaChart, Area, BarChart, Bar,
  XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
  ComposedChart, Scatter,
} from 'recharts'
import { dashboardApi } from '../services/api'
import { useAuthStore } from '../stores/authStore'
import {
  TrendingUp, TrendingDown, Calendar, Filter,
  Download, BarChart3, Activity, Users
} from 'lucide-react'

type TimeRange = '7d' | '30d' | '90d' | '1y'

export default function AnalyticsPage() {
  const [timeRange, setTimeRange] = useState<TimeRange>('30d')
  const [selectedRegion, setSelectedRegion] = useState<string>('')

  const user = useAuthStore((state) => state.user)

  const { data: analytics, isLoading } = useQuery({
    queryKey: ['analytics', timeRange, selectedRegion || user?.regionId],
    queryFn: () => dashboardApi.getAnalytics({
      timeRange,
      regionId: selectedRegion || user?.regionId,
    }),
  })

  const { data: regions } = useQuery({
    queryKey: ['regions'],
    queryFn: () => dashboardApi.getRegions(),
  })

  // Calculate trends
  const calculateTrend = (current: number, previous: number) => {
    if (!previous) return 0
    return ((current - previous) / previous) * 100
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Analytics</h1>
          <p className="text-gray-500 mt-1">
            Deep dive into maternal health metrics
          </p>
        </div>

        <div className="flex gap-3">
          {/* Time range selector */}
          <div className="flex bg-gray-100 rounded-lg p-1">
            {(['7d', '30d', '90d', '1y'] as TimeRange[]).map((range) => (
              <button
                key={range}
                onClick={() => setTimeRange(range)}
                className={`px-3 py-1.5 text-sm font-medium rounded-md transition-colors ${
                  timeRange === range
                    ? 'bg-white text-gray-900 shadow-sm'
                    : 'text-gray-600 hover:text-gray-900'
                }`}
              >
                {range === '7d' ? '7 Days' : range === '30d' ? '30 Days' : range === '90d' ? '90 Days' : '1 Year'}
              </button>
            ))}
          </div>

          {/* Region filter */}
          <select
            value={selectedRegion}
            onChange={(e) => setSelectedRegion(e.target.value)}
            className="px-3 py-2 border border-gray-200 rounded-lg text-sm"
          >
            <option value="">All Regions</option>
            {regions?.map((region: any) => (
              <option key={region.id} value={region.id}>
                {region.name}
              </option>
            ))}
          </select>

          {/* Export */}
          <button className="btn-secondary flex items-center gap-2">
            <Download size={18} />
            Export
          </button>
        </div>
      </div>

      {isLoading ? (
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600" />
        </div>
      ) : (
        <>
          {/* Summary KPIs */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <KPICard
              title="Screening Rate"
              value={analytics?.screeningRate || 0}
              format="percent"
              trend={analytics?.screeningRateTrend}
              icon={Activity}
            />
            <KPICard
              title="High Risk Identified"
              value={analytics?.highRiskCount || 0}
              trend={analytics?.highRiskTrend}
              icon={Users}
              subtitle="Out of total screenings"
            />
            <KPICard
              title="Referral Completion"
              value={analytics?.referralCompletionRate || 0}
              format="percent"
              trend={analytics?.referralTrend}
              icon={TrendingUp}
            />
            <KPICard
              title="Avg Response Time"
              value={analytics?.avgResponseTime || 0}
              format="minutes"
              trend={analytics?.responseTrend}
              icon={Calendar}
              invertTrend
            />
          </div>

          {/* Risk Trends Over Time */}
          <div className="card">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Risk Distribution Over Time
            </h3>
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={analytics?.riskTrends || []}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                <XAxis dataKey="date" stroke="#6b7280" fontSize={12} />
                <YAxis stroke="#6b7280" fontSize={12} />
                <Tooltip />
                <Legend />
                <Area
                  type="monotone"
                  dataKey="high"
                  stackId="1"
                  stroke="#ef4444"
                  fill="#fee2e2"
                  name="High Risk"
                />
                <Area
                  type="monotone"
                  dataKey="medium"
                  stackId="1"
                  stroke="#f97316"
                  fill="#ffedd5"
                  name="Medium Risk"
                />
                <Area
                  type="monotone"
                  dataKey="low"
                  stackId="1"
                  stroke="#22c55e"
                  fill="#dcfce7"
                  name="Low Risk"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>

          {/* Two column charts */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* ANC Visits Compliance */}
            <div className="card">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                ANC Visit Compliance
              </h3>
              <ResponsiveContainer width="100%" height={250}>
                <ComposedChart data={analytics?.ancCompliance || []}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis dataKey="week" stroke="#6b7280" fontSize={12} />
                  <YAxis yAxisId="left" stroke="#6b7280" fontSize={12} />
                  <YAxis yAxisId="right" orientation="right" stroke="#6b7280" fontSize={12} />
                  <Tooltip />
                  <Legend />
                  <Bar
                    yAxisId="left"
                    dataKey="expected"
                    fill="#e5e7eb"
                    name="Expected Visits"
                  />
                  <Bar
                    yAxisId="left"
                    dataKey="completed"
                    fill="#0ea5e9"
                    name="Completed Visits"
                  />
                  <Line
                    yAxisId="right"
                    type="monotone"
                    dataKey="rate"
                    stroke="#8b5cf6"
                    name="Compliance Rate %"
                    strokeWidth={2}
                  />
                </ComposedChart>
              </ResponsiveContainer>
            </div>

            {/* Top Risk Factors */}
            <div className="card">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                Contributing Risk Factors
              </h3>
              <ResponsiveContainer width="100%" height={250}>
                <BarChart
                  layout="vertical"
                  data={analytics?.topFactors || []}
                  margin={{ left: 80 }}
                >
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis type="number" stroke="#6b7280" fontSize={12} />
                  <YAxis type="category" dataKey="name" stroke="#6b7280" fontSize={12} />
                  <Tooltip />
                  <Bar dataKey="count" fill="#0ea5e9" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Gestational Age Distribution */}
          <div className="card">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Patient Distribution by Gestational Age
            </h3>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={analytics?.gestationalDistribution || []}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                <XAxis dataKey="range" stroke="#6b7280" fontSize={12} />
                <YAxis stroke="#6b7280" fontSize={12} />
                <Tooltip />
                <Bar dataKey="total" fill="#e5e7eb" name="Total" radius={[4, 4, 0, 0]} />
                <Bar dataKey="highRisk" fill="#ef4444" name="High Risk" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Facility Performance Table */}
          <div className="card">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Facility Performance
            </h3>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50 border-b">
                  <tr>
                    <th className="text-left px-4 py-3 text-sm font-medium text-gray-500">Facility</th>
                    <th className="text-right px-4 py-3 text-sm font-medium text-gray-500">Screenings</th>
                    <th className="text-right px-4 py-3 text-sm font-medium text-gray-500">High Risk</th>
                    <th className="text-right px-4 py-3 text-sm font-medium text-gray-500">Referrals</th>
                    <th className="text-right px-4 py-3 text-sm font-medium text-gray-500">Completion %</th>
                    <th className="text-right px-4 py-3 text-sm font-medium text-gray-500">Avg Response</th>
                  </tr>
                </thead>
                <tbody className="divide-y">
                  {analytics?.facilityPerformance?.map((facility: any) => (
                    <tr key={facility.id} className="hover:bg-gray-50">
                      <td className="px-4 py-3 text-sm font-medium text-gray-900">
                        {facility.name}
                      </td>
                      <td className="px-4 py-3 text-sm text-gray-600 text-right">
                        {facility.screenings}
                      </td>
                      <td className="px-4 py-3 text-sm text-right">
                        <span className="text-red-600 font-medium">
                          {facility.highRisk} ({Math.round(facility.highRiskRate)}%)
                        </span>
                      </td>
                      <td className="px-4 py-3 text-sm text-gray-600 text-right">
                        {facility.referrals}
                      </td>
                      <td className="px-4 py-3 text-sm text-right">
                        <span className={`font-medium ${
                          facility.completionRate >= 80
                            ? 'text-green-600'
                            : facility.completionRate >= 60
                            ? 'text-yellow-600'
                            : 'text-red-600'
                        }`}>
                          {facility.completionRate}%
                        </span>
                      </td>
                      <td className="px-4 py-3 text-sm text-gray-600 text-right">
                        {facility.avgResponse} min
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  )
}

interface KPICardProps {
  title: string
  value: number
  format?: 'number' | 'percent' | 'minutes'
  trend?: number
  icon: React.ElementType
  subtitle?: string
  invertTrend?: boolean
}

function KPICard({ title, value, format = 'number', trend, icon: Icon, subtitle, invertTrend }: KPICardProps) {
  const formatValue = () => {
    if (format === 'percent') return `${Math.round(value)}%`
    if (format === 'minutes') return `${Math.round(value)} min`
    return value.toLocaleString()
  }

  const trendColor = () => {
    if (!trend) return 'text-gray-500'
    const isPositive = trend > 0
    if (invertTrend) {
      return isPositive ? 'text-red-600' : 'text-green-600'
    }
    return isPositive ? 'text-green-600' : 'text-red-600'
  }

  return (
    <div className="card">
      <div className="flex items-center justify-between mb-2">
        <span className="text-sm text-gray-500">{title}</span>
        <Icon className="text-gray-400" size={20} />
      </div>
      <div className="text-2xl font-bold text-gray-900">{formatValue()}</div>
      {subtitle && <p className="text-xs text-gray-500 mt-1">{subtitle}</p>}
      {trend !== undefined && (
        <div className={`flex items-center gap-1 mt-2 text-sm ${trendColor()}`}>
          {trend > 0 ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
          {Math.abs(trend).toFixed(1)}% vs previous period
        </div>
      )}
    </div>
  )
}
