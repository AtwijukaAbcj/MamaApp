import { useQuery } from '@tanstack/react-query'
import { dashboardApi } from '../services/api'
import { useAuthStore } from '../stores/authStore'
import {
  Users,
  AlertTriangle,
  Ambulance,
  Activity,
  TrendingUp,
  TrendingDown,
} from 'lucide-react'
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
  CartesianGrid,
} from 'recharts'

const RISK_COLORS = {
  high: '#ef4444',
  medium: '#f97316',
  low: '#22c55e',
}

export default function DashboardPage() {
  const user = useAuthStore((state) => state.user)
  const regionId = user?.regionId

  const { data: overview, isLoading: overviewLoading } = useQuery({
    queryKey: ['dashboard-overview', regionId],
    queryFn: () => dashboardApi.getOverview(regionId),
  })

  const { data: riskDistribution } = useQuery({
    queryKey: ['risk-distribution', regionId],
    queryFn: () => dashboardApi.getRiskDistribution(regionId),
  })

  const { data: referralsByDay } = useQuery({
    queryKey: ['referrals-by-day', regionId],
    queryFn: () => dashboardApi.getReferralsByDay(regionId, 14),
  })

  const { data: topFactors } = useQuery({
    queryKey: ['top-factors', regionId],
    queryFn: () => dashboardApi.getTopFactors(regionId),
  })

  const { data: regionalData } = useQuery({
    queryKey: ['regional-comparison'],
    queryFn: () => dashboardApi.getRegionalComparison(),
    enabled: user?.role === 'admin',
  })

  if (overviewLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600" />
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500 mt-1">
          {user?.role === 'admin' ? 'National Overview' : `${user?.regionId || 'Regional'} Overview`}
        </p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          icon={Users}
          label="Active Pregnancies"
          value={overview?.activePregnancies || 0}
          trend={overview?.pregnancyTrend}
          color="primary"
        />
        <StatCard
          icon={AlertTriangle}
          label="High Risk Cases"
          value={overview?.highRiskCases || 0}
          trend={overview?.highRiskTrend}
          color="red"
        />
        <StatCard
          icon={Ambulance}
          label="Pending Referrals"
          value={overview?.pendingReferrals || 0}
          color="orange"
        />
        <StatCard
          icon={Activity}
          label="Readings Today"
          value={overview?.readingsToday || 0}
          color="green"
        />
      </div>

      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Risk Distribution */}
        <div className="card">
          <h3 className="text-lg font-semibold mb-4">Risk Distribution</h3>
          <div className="h-64">
            {riskDistribution && (
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={[
                      { name: 'High Risk', value: riskDistribution.high, color: RISK_COLORS.high },
                      { name: 'Medium Risk', value: riskDistribution.medium, color: RISK_COLORS.medium },
                      { name: 'Low Risk', value: riskDistribution.low, color: RISK_COLORS.low },
                    ]}
                    dataKey="value"
                    nameKey="name"
                    cx="50%"
                    cy="50%"
                    outerRadius={80}
                    label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                  >
                    {[
                      { color: RISK_COLORS.high },
                      { color: RISK_COLORS.medium },
                      { color: RISK_COLORS.low },
                    ].map((entry, index) => (
                      <Cell key={index} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            )}
          </div>
          <div className="flex justify-center gap-6 mt-4">
            <LegendItem color={RISK_COLORS.high} label="High" />
            <LegendItem color={RISK_COLORS.medium} label="Medium" />
            <LegendItem color={RISK_COLORS.low} label="Low" />
          </div>
        </div>

        {/* Referrals Trend */}
        <div className="card">
          <h3 className="text-lg font-semibold mb-4">Referrals (Last 14 Days)</h3>
          <div className="h-64">
            {referralsByDay && (
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={referralsByDay}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
                  <XAxis
                    dataKey="date"
                    tickFormatter={(d) => new Date(d).toLocaleDateString('en-US', { day: 'numeric', month: 'short' })}
                    tick={{ fontSize: 12 }}
                  />
                  <YAxis tick={{ fontSize: 12 }} />
                  <Tooltip
                    labelFormatter={(d) => new Date(d).toLocaleDateString()}
                    formatter={(value: number) => [value, 'Referrals']}
                  />
                  <Line
                    type="monotone"
                    dataKey="count"
                    stroke="#ec4899"
                    strokeWidth={2}
                    dot={{ r: 4 }}
                  />
                </LineChart>
              </ResponsiveContainer>
            )}
          </div>
        </div>
      </div>

      {/* Bottom row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Top Risk Factors */}
        <div className="card">
          <h3 className="text-lg font-semibold mb-4">Top Risk Factors (AI Analysis)</h3>
          <div className="h-64">
            {topFactors && (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={topFactors} layout="vertical">
                  <XAxis type="number" tick={{ fontSize: 12 }} />
                  <YAxis
                    type="category"
                    dataKey="factor"
                    width={120}
                    tick={{ fontSize: 12 }}
                  />
                  <Tooltip />
                  <Bar dataKey="count" fill="#ec4899" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            )}
          </div>
        </div>

        {/* Regional Comparison (admin only) */}
        {user?.role === 'admin' && regionalData && (
          <div className="card">
            <h3 className="text-lg font-semibold mb-4">Regional Comparison</h3>
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={regionalData}>
                  <XAxis dataKey="region" tick={{ fontSize: 11 }} />
                  <YAxis tick={{ fontSize: 12 }} />
                  <Tooltip />
                  <Bar dataKey="highRisk" name="High Risk" fill={RISK_COLORS.high} stackId="risk" />
                  <Bar dataKey="mediumRisk" name="Medium Risk" fill={RISK_COLORS.medium} stackId="risk" />
                  <Bar dataKey="lowRisk" name="Low Risk" fill={RISK_COLORS.low} stackId="risk" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        )}

        {/* Recent alerts */}
        <div className="card">
          <h3 className="text-lg font-semibold mb-4">Recent Alerts</h3>
          <div className="space-y-3">
            {overview?.recentAlerts?.length > 0 ? (
              overview.recentAlerts.map((alert: { id: string; message: string; severity: string; time: string }) => (
                <div
                  key={alert.id}
                  className={`p-3 rounded-lg border-l-4 ${
                    alert.severity === 'critical'
                      ? 'bg-red-50 border-red-500'
                      : 'bg-orange-50 border-orange-500'
                  }`}
                >
                  <p className="text-sm font-medium">{alert.message}</p>
                  <p className="text-xs text-gray-500 mt-1">{alert.time}</p>
                </div>
              ))
            ) : (
              <p className="text-gray-500 text-sm">No recent alerts</p>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

function StatCard({
  icon: Icon,
  label,
  value,
  trend,
  color,
}: {
  icon: React.ElementType
  label: string
  value: number | string
  trend?: number
  color: 'primary' | 'red' | 'orange' | 'green'
}) {
  const colorClasses = {
    primary: 'bg-primary-50 text-primary-600',
    red: 'bg-red-50 text-red-600',
    orange: 'bg-orange-50 text-orange-600',
    green: 'bg-green-50 text-green-600',
  }

  return (
    <div className="stat-card">
      <div className="flex items-center justify-between">
        <div className={`p-3 rounded-xl ${colorClasses[color]}`}>
          <Icon size={24} />
        </div>
        {trend !== undefined && (
          <div className={`flex items-center gap-1 text-sm ${trend >= 0 ? 'text-green-600' : 'text-red-600'}`}>
            {trend >= 0 ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
            {Math.abs(trend)}%
          </div>
        )}
      </div>
      <div className="mt-4">
        <p className="stat-value">{value.toLocaleString()}</p>
        <p className="stat-label">{label}</p>
      </div>
    </div>
  )
}

function LegendItem({ color, label }: { color: string; label: string }) {
  return (
    <div className="flex items-center gap-2">
      <div className="w-3 h-3 rounded-full" style={{ backgroundColor: color }} />
      <span className="text-sm text-gray-600">{label}</span>
    </div>
  )
}
