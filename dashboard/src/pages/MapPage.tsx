import { useEffect, useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { MapContainer, TileLayer, Marker, Popup, CircleMarker, useMap } from 'react-leaflet'
import { Icon, divIcon } from 'leaflet'
import MarkerClusterGroup from 'react-leaflet-cluster'
import { dashboardApi, facilitiesApi } from '../services/api'
import { useAuthStore } from '../stores/authStore'
import { Filter, Layers, Navigation } from 'lucide-react'
import 'leaflet/dist/leaflet.css'

// Fix Leaflet marker icon
import markerIcon from 'leaflet/dist/images/marker-icon.png'
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png'
import markerShadow from 'leaflet/dist/images/marker-shadow.png'

const defaultIcon = new Icon({
  iconUrl: markerIcon,
  iconRetinaUrl: markerIcon2x,
  shadowUrl: markerShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
})

// Cluster icon creator
const createClusterIcon = (count: number, risk: 'high' | 'medium' | 'low') => {
  const colors = {
    high: 'bg-red-500',
    medium: 'bg-orange-500',
    low: 'bg-green-500',
  }
  return divIcon({
    html: `<div class="cluster-marker ${colors[risk]}">${count}</div>`,
    className: 'custom-cluster-icon',
    iconSize: [40, 40],
  })
}

// Map center updater component
function MapCenterUpdater({ center }: { center: [number, number] }) {
  const map = useMap()
  useEffect(() => {
    map.setView(center, map.getZoom())
  }, [center, map])
  return null
}

export default function MapPage() {
  const [showFacilities, setShowFacilities] = useState(true)
  const [showHighRisk, setShowHighRisk] = useState(true)
  const [showPending, setShowPending] = useState(true)
  const [center, setCenter] = useState<[number, number]>([0.3476, 32.5825]) // Uganda center

  const user = useAuthStore((state) => state.user)

  // Fetch facilities
  const { data: facilities } = useQuery({
    queryKey: ['facilities'],
    queryFn: () => facilitiesApi.list(),
  })

  // Fetch map data (hotspots)
  const { data: mapData } = useQuery({
    queryKey: ['map-data', user?.regionId],
    queryFn: () => dashboardApi.getMapData(user?.regionId),
  })

  // Recenter on user location
  const handleRecenter = () => {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        setCenter([position.coords.latitude, position.coords.longitude])
      },
      () => {
        // Fallback to default
        setCenter([0.3476, 32.5825])
      }
    )
  }

  return (
    <div className="h-[calc(100vh-10rem)] flex flex-col">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Geographic Overview</h1>
          <p className="text-gray-500 mt-1">
            View facilities and high-risk areas
          </p>
        </div>

        <div className="flex gap-2">
          <button
            onClick={handleRecenter}
            className="btn-secondary flex items-center gap-2"
          >
            <Navigation size={18} />
            My Location
          </button>
        </div>
      </div>

      {/* Map filters */}
      <div className="card mb-4">
        <div className="flex flex-wrap items-center gap-4">
          <div className="flex items-center gap-2 text-sm font-medium text-gray-600">
            <Layers size={18} />
            Layers:
          </div>
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={showFacilities}
              onChange={(e) => setShowFacilities(e.target.checked)}
              className="rounded"
            />
            <span className="text-sm">Facilities</span>
          </label>
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={showHighRisk}
              onChange={(e) => setShowHighRisk(e.target.checked)}
              className="rounded"
            />
            <span className="text-sm text-red-600">High Risk Areas</span>
          </label>
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={showPending}
              onChange={(e) => setShowPending(e.target.checked)}
              className="rounded"
            />
            <span className="text-sm text-yellow-600">Pending Referrals</span>
          </label>
        </div>
      </div>

      {/* Map */}
      <div className="flex-1 rounded-xl overflow-hidden shadow-lg border border-gray-200">
        <MapContainer
          center={center}
          zoom={7}
          className="h-full w-full"
          scrollWheelZoom={true}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          <MapCenterUpdater center={center} />

          {/* Facilities */}
          {showFacilities && facilities?.map((facility: any) => (
            facility.latitude && facility.longitude && (
              <Marker
                key={facility.id}
                position={[facility.latitude, facility.longitude]}
                icon={defaultIcon}
              >
                <Popup>
                  <div className="p-2">
                    <h3 className="font-semibold">{facility.name}</h3>
                    <p className="text-sm text-gray-600">Level: {facility.level}</p>
                    {facility.bedCount && (
                      <p className="text-sm text-gray-600">Beds: {facility.bedCount}</p>
                    )}
                    {facility.hasEmoc && (
                      <span className="inline-block mt-1 px-2 py-0.5 bg-green-100 text-green-700 text-xs rounded">
                        EmOC Available
                      </span>
                    )}
                  </div>
                </Popup>
              </Marker>
            )
          ))}

          {/* High risk hotspots */}
          {showHighRisk && mapData?.hotspots?.map((hotspot: any, index: number) => (
            <CircleMarker
              key={`hotspot-${index}`}
              center={[hotspot.latitude, hotspot.longitude]}
              radius={Math.min(40, Math.max(15, hotspot.count * 2))}
              pathOptions={{
                color: '#ef4444',
                fillColor: '#ef4444',
                fillOpacity: 0.4,
                weight: 2,
              }}
            >
              <Popup>
                <div className="p-2">
                  <h3 className="font-semibold text-red-600">High Risk Area</h3>
                  <p className="text-sm">{hotspot.regionName || 'Unknown Region'}</p>
                  <p className="text-sm text-gray-600">{hotspot.count} high-risk patients</p>
                </div>
              </Popup>
            </CircleMarker>
          ))}

          {/* Pending referrals */}
          {showPending && mapData?.pendingReferrals?.map((referral: any) => (
            referral.fromLatitude && referral.fromLongitude && (
              <CircleMarker
                key={`ref-${referral.id}`}
                center={[referral.fromLatitude, referral.fromLongitude]}
                radius={10}
                pathOptions={{
                  color: referral.urgency === 'emergency' ? '#dc2626' : '#f59e0b',
                  fillColor: referral.urgency === 'emergency' ? '#dc2626' : '#f59e0b',
                  fillOpacity: 0.7,
                  weight: 2,
                }}
              >
                <Popup>
                  <div className="p-2">
                    <h3 className="font-semibold">
                      Pending {referral.urgency === 'emergency' ? '🚨 Emergency' : 'Referral'}
                    </h3>
                    <p className="text-sm">{referral.patientName}</p>
                    <p className="text-sm text-gray-600">
                      {referral.fromFacilityName} → {referral.toFacilityName}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      {new Date(referral.createdAt).toLocaleString()}
                    </p>
                  </div>
                </Popup>
              </CircleMarker>
            )
          ))}
        </MapContainer>
      </div>

      {/* Legend */}
      <div className="mt-4 flex gap-6 text-sm">
        <div className="flex items-center gap-2">
          <div className="w-4 h-4 bg-blue-500 rounded"></div>
          <span>Facility</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-4 h-4 bg-red-500 rounded-full opacity-60"></div>
          <span>High Risk Area</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-4 h-4 bg-orange-500 rounded-full"></div>
          <span>Pending Referral</span>
        </div>
      </div>

      {/* Custom cluster styles */}
      <style>{`
        .cluster-marker {
          width: 40px;
          height: 40px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
          font-weight: bold;
          font-size: 14px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }
        .custom-cluster-icon {
          background: transparent;
        }
      `}</style>
    </div>
  )
}
