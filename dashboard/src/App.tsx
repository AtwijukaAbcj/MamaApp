import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuthStore } from './stores/authStore'
import Layout from './components/Layout'
import LoginPage from './pages/LoginPage'
import DashboardPage from './pages/DashboardPage'
import PatientsPage from './pages/PatientsPage'
import ReferralsPage from './pages/ReferralsPage'
import MapPage from './pages/MapPage'
import AnalyticsPage from './pages/AnalyticsPage'
import FacilitiesPage from './pages/FacilitiesPage'

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated)
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }
  
  return <>{children}</>
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      
      <Route
        path="/"
        element={
          <ProtectedRoute>
            <Layout />
          </ProtectedRoute>
        }
      >
        <Route index element={<DashboardPage />} />
        <Route path="patients" element={<PatientsPage />} />
        <Route path="referrals" element={<ReferralsPage />} />
        <Route path="map" element={<MapPage />} />
        <Route path="analytics" element={<AnalyticsPage />} />
        <Route path="facilities" element={<FacilitiesPage />} />
      </Route>
    </Routes>
  )
}
