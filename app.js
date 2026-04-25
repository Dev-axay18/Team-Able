// ============================================================
//  SUPABASE INIT
// ============================================================
const SUPABASE_URL     = 'https://zkmawrdnmhdgmthxfmnl.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprbWF3cmRubWhkZ210aHhmbW5sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcwNjA4MTQsImV4cCI6MjA5MjYzNjgxNH0.ZsPqT6KOTigeXdA5xvTIFvltLEsgVDrMc8PMup2l3ak';

const db = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Resolved after loadHospitalData() runs
let HOSPITAL_ID = null;

// Cached so toggleEmergency() can flip it without a re-fetch
let currentEmergencyState = null;

// ============================================================
//  TOAST
// ============================================================
function showToast(message, type = 'success') {
  const icons = {
    success: `<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>`,
    error:   `<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>`,
    info:    `<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>`,
  };
  const toast = document.getElementById('toast');
  toast.innerHTML = `${icons[type] || ''}<span>${message}</span>`;
  toast.className = `toast ${type} show`;
  clearTimeout(toast._t);
  toast._t = setTimeout(() => toast.classList.remove('show'), 3500);
}

// ============================================================
//  NAVIGATION
// ============================================================
function initNavigation() {
  const navItems = document.querySelectorAll('.nav-item');
  const sections = document.querySelectorAll('.content-section');
  const pageTitle = document.getElementById('page-title');
  const titles = { overview: 'Overview', beds: 'Bed Categories', drivers: 'Ambulance Drivers', patients: 'Patients', emergency: 'Emergency' };

  navItems.forEach(item => {
    item.addEventListener('click', e => {
      e.preventDefault();
      const target = item.dataset.section;
      navItems.forEach(n => n.classList.remove('active'));
      item.classList.add('active');
      sections.forEach(s => s.classList.remove('active'));
      document.getElementById(`section-${target}`)?.classList.add('active');
      pageTitle.textContent = titles[target] || target;
      if (target === 'beds')     loadBedTable();
      if (target === 'drivers')  loadDrivers();
      if (target === 'patients') loadPatients();
    });
  });
}

// ============================================================
//  HEADER DATE
// ============================================================
function setHeaderDate() {
  document.getElementById('header-date').textContent = new Date().toLocaleDateString('en-US', {
    weekday: 'short', year: 'numeric', month: 'short', day: 'numeric'
  });
}

// ============================================================
//  LOAD HOSPITAL DATA
//  Fetches the first hospital row and populates all stat cards,
//  the header name, sidebar, and emergency toggle.
// ============================================================
async function loadHospitalData() {
  // SELECT first hospital row — no hardcoded UUID needed
  const { data, error } = await db
    .from('hospitals')
    .select('id, name, total_beds, available_beds, icu_available, emergency_ready_ward, general_ward_beds, private_room_beds, pediatric_beds, maternity_beds, isolation_beds, burn_unit_beds')
    .limit(5);

  console.log('hospitals →', { data, error });

  if (error) {
    console.error('loadHospitalData error:', error.message);
    showToast('Could not load hospital data.', 'error');
    return;
  }

  if (!data || data.length === 0) {
    console.warn('No rows returned from hospitals. Check RLS policies.');
    showToast('No hospital records found — check RLS in Supabase.', 'error');
    return;
  }

  const h = data[0];
  HOSPITAL_ID = h.id;

  // Bed stat cards
  setText('total-beds-value',     h.total_beds     ?? '—');
  setText('available-beds-value', h.available_beds ?? '—');
  setText('icu-value',            h.icu_available  ?? '—');

  // Bed category cards
  setText('general-ward-value',  h.general_ward_beds  ?? '—');
  setText('icu-cat-value',       h.icu_available      ?? '—');
  setText('private-room-value',  h.private_room_beds  ?? '—');
  setText('pediatric-value',     h.pediatric_beds     ?? '—');
  setText('maternity-value',     h.maternity_beds     ?? '—');
  setText('isolation-value',     h.isolation_beds     ?? '—');
  setText('burn-unit-value',     h.burn_unit_beds     ?? '—');

  // Hospital name
  const name = h.name || 'Hospital';
  setText('hospital-name-header',  name);
  setText('sidebar-hospital-name', name);
  setText('sidebar-avatar',        name.charAt(0).toUpperCase());

  // Emergency toggle
  currentEmergencyState = h.emergency_ready_ward;
  renderEmergencyUI(currentEmergencyState);
}

// ============================================================
//  LOAD SYSTEM-WIDE COUNTS
//  Queries users and ambulance_drivers tables for summary stats.
// ============================================================
async function loadCounts() {
  // COUNT all patients (users table)
  // Supabase returns count in the response when you pass { count: 'exact', head: true }
  const { count: patientCount, error: pErr } = await db
    .from('users')
    .select('*', { count: 'exact', head: true });

  if (pErr) console.error('patient count error:', pErr.message);
  else setText('total-patients-value', patientCount ?? '—');

  // COUNT all ambulance drivers for this hospital
  const { count: totalDrivers, error: dErr } = await db
    .from('ambulance_drivers')
    .select('*', { count: 'exact', head: true })
    .eq('associated_hospital_id', HOSPITAL_ID);

  if (dErr) console.error('driver count error:', dErr.message);
  else setText('total-ambulances-value', totalDrivers ?? '—');

  // COUNT approved drivers
  const { count: approvedCount, error: aErr } = await db
    .from('ambulance_drivers')
    .select('*', { count: 'exact', head: true })
    .eq('associated_hospital_id', HOSPITAL_ID)
    .eq('is_approved', true);

  if (aErr) console.error('approved count error:', aErr.message);
  else setText('approved-drivers-value', approvedCount ?? '—');

  // COUNT pending drivers
  const { count: pendingCount, error: peErr } = await db
    .from('ambulance_drivers')
    .select('*', { count: 'exact', head: true })
    .eq('associated_hospital_id', HOSPITAL_ID)
    .eq('is_approved', false);

  if (peErr) console.error('pending count error:', peErr.message);
  else setText('pending-drivers-value', pendingCount ?? '—');
}

// ============================================================
//  EMERGENCY WARD UI
// ============================================================
function renderEmergencyUI(isReady) {
  const pairs = [
    ['emergency-label',       'emergency-label-2'],
    ['emergency-toggle-btn',  'emergency-toggle-btn-2'],
    ['emergency-status-bar',  'emergency-status-bar-2'],
    ['emergency-indicator',   'emergency-indicator-2'],
    ['emergency-status-text', 'emergency-status-text-2'],
  ];

  pairs[0].forEach(id => setText(id, isReady ? 'Ready' : 'Full'));

  pairs[1].forEach(id => {
    const el = document.getElementById(id);
    if (!el) return;
    el.classList.toggle('active',   isReady);
    el.classList.toggle('inactive', !isReady);
  });

  pairs[2].forEach(id => {
    const el = document.getElementById(id);
    if (!el) return;
    el.classList.toggle('ready', isReady);
    el.classList.toggle('full',  !isReady);
  });

  pairs[3].forEach(id => {
    const el = document.getElementById(id);
    if (!el) return;
    el.classList.toggle('ready', isReady);
    el.classList.toggle('full',  !isReady);
  });

  pairs[4].forEach(id => setText(id,
    isReady
      ? '✓ Emergency ward is open and accepting patients'
      : '✗ Emergency ward is currently full — not accepting patients'
  ));
}

// ============================================================
//  TOGGLE EMERGENCY WARD
// ============================================================
async function toggleEmergency() {
  if (currentEmergencyState === null) return;
  const newState = !currentEmergencyState;

  // Optimistic update
  currentEmergencyState = newState;
  renderEmergencyUI(newState);

  const { error } = await db
    .from('hospitals')
    .update({ emergency_ready_ward: newState })
    .eq('id', HOSPITAL_ID);

  if (error) {
    console.error('toggleEmergency error:', error.message);
    currentEmergencyState = !newState;
    renderEmergencyUI(!newState);
    showToast('Failed to update emergency status.', 'error');
    return;
  }

  showToast(newState ? 'Emergency ward marked as Ready.' : 'Emergency ward marked as Full.', 'success');
}

// ============================================================
//  UPDATE BED FIELD
// ============================================================
async function updateField(field, inputId, displayId) {
  const input = document.getElementById(inputId);
  const raw = input.value.trim();

  if (raw === '' || isNaN(raw) || Number(raw) < 0) {
    showToast('Enter a valid non-negative number.', 'error');
    return;
  }

  const val = parseInt(raw, 10);

  const { error } = await db
    .from('hospitals')
    .update({ [field]: val })
    .eq('id', HOSPITAL_ID);

  if (error) {
    console.error(`updateField(${field}) error:`, error.message);
    showToast(`Failed to update ${field.replace(/_/g, ' ')}.`, 'error');
    return;
  }

  setText(displayId, val);
  input.value = '';
  showToast(`Updated to ${val} successfully.`, 'success');
}

// ============================================================
//  TOGGLE ADD DRIVER FORM
// ============================================================
function toggleAddDriverForm() {
  const form = document.getElementById('add-driver-form');
  const isHidden = form.style.display === 'none';
  form.style.display = isHidden ? 'block' : 'none';
  if (isHidden) {
    // Clear all fields when opening
    ['drv-name','drv-mobile','drv-password','drv-license','drv-plate'].forEach(id => {
      document.getElementById(id).value = '';
    });
    document.getElementById('drv-approved').value = 'false';
    document.getElementById('drv-name').focus();
  }
}

// ============================================================
//  ADD DRIVER
//  Inserts a new row into ambulance_drivers linked to this hospital.
//  Note: password_hash stores the raw password here for prototype
//  purposes. In production, hash it server-side via an Edge Function.
// ============================================================
async function addDriver() {
  const name     = document.getElementById('drv-name').value.trim();
  const mobile   = document.getElementById('drv-mobile').value.trim();
  const password = document.getElementById('drv-password').value.trim();
  const license  = document.getElementById('drv-license').value.trim();
  const plate    = document.getElementById('drv-plate').value.trim();
  const approved = document.getElementById('drv-approved').value === 'true';

  // Validation
  if (!name || !mobile || !password || !license || !plate) {
    showToast('Please fill in all required fields.', 'error');
    return;
  }
  if (password.length < 6) {
    showToast('Password must be at least 6 characters.', 'error');
    return;
  }

  const btn = document.getElementById('btn-submit-driver');
  btn.disabled = true;
  btn.innerHTML = `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/></svg> Saving...`;

  // INSERT new driver row
  const { error } = await db
    .from('ambulance_drivers')
    .insert({
      name,
      mobile_number:          mobile,
      password_hash:          password,   // hash server-side in production
      drivers_license:        license,
      ambulance_number_plate: plate,
      is_approved:            approved,
      associated_hospital_id: HOSPITAL_ID,
    });

  btn.disabled = false;
  btn.innerHTML = `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg> Save Driver`;

  if (error) {
    console.error('addDriver error:', error.message);
    // Friendly message for unique constraint violations
    if (error.message.includes('mobile_number'))       showToast('Mobile number already registered.', 'error');
    else if (error.message.includes('drivers_license')) showToast('License number already registered.', 'error');
    else if (error.message.includes('number_plate'))    showToast('Number plate already registered.', 'error');
    else showToast('Failed to add driver.', 'error');
    return;
  }

  showToast(`Driver "${name}" added successfully.`, 'success');
  toggleAddDriverForm();
  loadDrivers();
  loadCounts();
}

// ============================================================
//  LOAD DRIVERS TABLE
// ============================================================
async function loadDrivers() {
  const tbody = document.getElementById('drivers-tbody');
  if (!HOSPITAL_ID) {
    tbody.innerHTML = `<tr><td colspan="6" class="table-empty">Hospital not loaded yet.</td></tr>`;
    return;
  }
  tbody.innerHTML = `<tr><td colspan="6" class="table-loading">Loading drivers...</td></tr>`;

  const { data, error } = await db
    .from('ambulance_drivers')
    .select('id, name, mobile_number, ambulance_number_plate, drivers_license, is_approved')
    .eq('associated_hospital_id', HOSPITAL_ID)
    .order('name', { ascending: true });

  if (error) {
    console.error('loadDrivers error:', error.message);
    tbody.innerHTML = `<tr><td colspan="6" class="table-empty">Failed to load drivers.</td></tr>`;
    showToast('Failed to load drivers.', 'error');
    return;
  }

  if (!data || data.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" class="table-empty">No drivers yet. Click "Add Driver" to get started.</td></tr>`;
    return;
  }

  tbody.innerHTML = data.map(d => `
    <tr id="driver-row-${d.id}">
      <td><span class="cell-name">${esc(d.name)}</span></td>
      <td><span class="cell-mono">${esc(d.mobile_number)}</span></td>
      <td><span class="cell-plate">${esc(d.ambulance_number_plate)}</span></td>
      <td><span class="cell-mono">${esc(d.drivers_license)}</span></td>
      <td>${d.is_approved
        ? `<span class="badge badge-green">Approved</span>`
        : `<span class="badge badge-orange">Pending</span>`
      }</td>
      <td>
        <div class="action-cell">
          ${!d.is_approved
            ? `<button class="btn-approve" onclick="approveDriver('${d.id}')">Approve</button>`
            : `<span style="color:var(--gray-300);font-size:0.78rem;">—</span>`
          }
          <button class="btn-delete" onclick="deleteDriver('${d.id}', '${esc(d.name)}')">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6M14 11v6"/><path d="M9 6V4h6v2"/></svg>
            Delete
          </button>
        </div>
      </td>
    </tr>
  `).join('');
}

// ============================================================
//  APPROVE DRIVER
// ============================================================
async function approveDriver(driverId) {
  const btn = document.querySelector(`#driver-row-${driverId} .btn-approve`);
  if (btn) { btn.disabled = true; btn.textContent = 'Approving...'; }

  const { error } = await db
    .from('ambulance_drivers')
    .update({ is_approved: true })
    .eq('id', driverId);

  if (error) {
    console.error('approveDriver error:', error.message);
    showToast('Failed to approve driver.', 'error');
    if (btn) { btn.disabled = false; btn.textContent = 'Approve'; }
    return;
  }

  const row = document.getElementById(`driver-row-${driverId}`);
  if (row) {
    row.cells[4].innerHTML = `<span class="badge badge-green">Approved</span>`;
    row.cells[5].innerHTML = `<div class="action-cell"><span style="color:var(--gray-300);font-size:0.78rem;">—</span><button class="btn-delete" onclick="deleteDriver('${driverId}', '')"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6M14 11v6"/><path d="M9 6V4h6v2"/></svg>Delete</button></div>`;
  }

  loadCounts();
  showToast('Driver approved successfully.', 'success');
}

// ============================================================
//  DELETE DRIVER
//  Asks for confirmation then deletes the row from Supabase.
// ============================================================
async function deleteDriver(driverId, driverName) {
  const label = driverName || 'this driver';
  if (!confirm(`Are you sure you want to delete "${label}"? This cannot be undone.`)) return;

  const row = document.getElementById(`driver-row-${driverId}`);
  if (row) row.style.opacity = '0.4';

  // DELETE row by primary key
  const { error } = await db
    .from('ambulance_drivers')
    .delete()
    .eq('id', driverId);

  if (error) {
    console.error('deleteDriver error:', error.message);
    showToast('Failed to delete driver.', 'error');
    if (row) row.style.opacity = '1';
    return;
  }

  // Remove row from DOM instantly
  if (row) row.remove();
  loadCounts();
  showToast(`Driver "${label}" deleted.`, 'success');

  // Show empty state if no rows left
  const tbody = document.getElementById('drivers-tbody');
  if (tbody && tbody.children.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" class="table-empty">No drivers yet. Click "Add Driver" to get started.</td></tr>`;
  }
}

// ============================================================
//  LOAD PATIENTS TABLE
//  Reads from the `users` table — view only, no edits.
// ============================================================
async function loadPatients() {
  const tbody = document.getElementById('patients-tbody');
  tbody.innerHTML = `<tr><td colspan="6" class="table-loading">Loading patients...</td></tr>`;

  // SELECT patient records — sensitive fields like aadhar/mpin are excluded
  const { data, error } = await db
    .from('users')
    .select('id, name, mobile_number, blood_type, gender, emergency_contact, is_mobile_verified')
    .order('name', { ascending: true });

  if (error) {
    console.error('loadPatients error:', error.message);
    tbody.innerHTML = `<tr><td colspan="6" class="table-empty">Failed to load patients.</td></tr>`;
    showToast('Failed to load patients.', 'error');
    return;
  }

  if (!data || data.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" class="table-empty">No patients registered yet.</td></tr>`;
    return;
  }

  tbody.innerHTML = data.map(p => `
    <tr>
      <td><span class="cell-name">${esc(p.name)}</span></td>
      <td><span class="cell-mono">${esc(p.mobile_number)}</span></td>
      <td>${p.blood_type
        ? `<span class="badge badge-red">${esc(p.blood_type)}</span>`
        : `<span style="color:var(--gray-400)">—</span>`
      }</td>
      <td>${p.gender
        ? `<span class="badge badge-purple">${esc(p.gender)}</span>`
        : `<span style="color:var(--gray-400)">—</span>`
      }</td>
      <td><span class="cell-mono">${esc(p.emergency_contact) || '—'}</span></td>
      <td>${p.is_mobile_verified
        ? `<span class="badge badge-green">Verified</span>`
        : `<span class="badge badge-orange">Unverified</span>`
      }</td>
    </tr>
  `).join('');
}

// ============================================================
//  LOAD BED CATEGORIES TABLE
//  Reads all bed columns from hospitals and renders a detailed
//  table with occupancy bars and inline update inputs.
// ============================================================
async function loadBedTable() {
  const tbody = document.getElementById('beds-tbody');
  tbody.innerHTML = `<tr><td colspan="5" class="table-loading">Loading bed data...</td></tr>`;

  const { data, error } = await db
    .from('hospitals')
    .select('id, name, total_beds, available_beds, icu_available, general_ward_beds, private_room_beds, pediatric_beds, maternity_beds, isolation_beds, burn_unit_beds')
    .limit(5);

  if (error || !data || data.length === 0) {
    console.error('loadBedTable error:', error?.message);
    tbody.innerHTML = `<tr><td colspan="5" class="table-empty">Failed to load bed data.</td></tr>`;
    return;
  }

  const h = data[0];

  // Update summary bar
  const occupied = h.total_beds - h.available_beds;
  const occupancyPct = h.total_beds > 0 ? Math.round((occupied / h.total_beds) * 100) : 0;
  setText('bs-total',     h.total_beds     ?? '—');
  setText('bs-available', h.available_beds ?? '—');
  setText('bs-icu',       h.icu_available  ?? '—');
  setText('bs-occupancy', h.total_beds > 0 ? `${occupancyPct}%` : '—');

  // Define all bed categories
  const categories = [
    { label: 'General Ward',   field: 'general_ward_beds',  value: h.general_ward_beds,  icon: 'blue',   total: h.total_beds },
    { label: 'ICU',            field: 'icu_available',      value: h.icu_available,       icon: 'orange', total: h.total_beds },
    { label: 'Private Rooms',  field: 'private_room_beds',  value: h.private_room_beds,  icon: 'purple', total: h.total_beds },
    { label: 'Pediatric',      field: 'pediatric_beds',     value: h.pediatric_beds,     icon: 'teal',   total: h.total_beds },
    { label: 'Maternity',      field: 'maternity_beds',     value: h.maternity_beds,     icon: 'green',  total: h.total_beds },
    { label: 'Isolation',      field: 'isolation_beds',     value: h.isolation_beds,     icon: 'red',    total: h.total_beds },
    { label: 'Burn Unit',      field: 'burn_unit_beds',     value: h.burn_unit_beds,     icon: 'red',    total: h.total_beds },
    { label: 'Total Beds',     field: 'total_beds',         value: h.total_beds,         icon: 'blue',   total: h.total_beds },
    { label: 'Available Beds', field: 'available_beds',     value: h.available_beds,     icon: 'green',  total: h.total_beds },
  ];

  tbody.innerHTML = categories.map(cat => {
    const pct   = cat.total > 0 ? Math.round((cat.value / cat.total) * 100) : 0;
    const fill  = pct >= 80 ? 'high' : pct >= 50 ? 'medium' : 'low';
    const inputId = `bed-input-${cat.field}`;
    const dispId  = `bed-disp-${cat.field}`;

    // Status badge based on value
    let statusBadge;
    if (cat.value === 0)       statusBadge = `<span class="badge badge-red">Empty</span>`;
    else if (pct >= 80)        statusBadge = `<span class="badge badge-orange">High Load</span>`;
    else                       statusBadge = `<span class="badge badge-green">Available</span>`;

    return `
      <tr>
        <td>
          <div style="display:flex;align-items:center;gap:8px;">
            <div class="stat-icon ${cat.icon}" style="width:28px;height:28px;flex-shrink:0;"></div>
            <span class="cell-name">${cat.label}</span>
          </div>
        </td>
        <td><span id="${dispId}" class="cell-name">${cat.value ?? '—'}</span></td>
        <td>
          <div class="occupancy-bar-wrap">
            <div class="occupancy-bar">
              <div class="occupancy-fill ${fill}" style="width:${pct}%"></div>
            </div>
            <span class="occupancy-pct">${pct}%</span>
          </div>
        </td>
        <td>${statusBadge}</td>
        <td>
          <div style="display:flex;align-items:center;gap:0;">
            <input type="number" id="${inputId}" class="inline-input" placeholder="New value" min="0"/>
            <button class="btn-save-inline" onclick="updateBedRow('${cat.field}','${inputId}','${dispId}')">Save</button>
          </div>
        </td>
      </tr>
    `;
  }).join('');
}

// ============================================================
//  UPDATE A BED ROW INLINE
// ============================================================
async function updateBedRow(field, inputId, dispId) {
  const input = document.getElementById(inputId);
  const raw = input.value.trim();

  if (raw === '' || isNaN(raw) || Number(raw) < 0) {
    showToast('Enter a valid non-negative number.', 'error');
    return;
  }

  const val = parseInt(raw, 10);

  const { error } = await db
    .from('hospitals')
    .update({ [field]: val })
    .eq('id', HOSPITAL_ID);

  if (error) {
    console.error(`updateBedRow(${field}) error:`, error.message);
    showToast(`Failed to update.`, 'error');
    return;
  }

  setText(dispId, val);
  input.value = '';
  showToast(`Updated to ${val}.`, 'success');

  // Refresh overview cards and bed table to stay in sync
  loadHospitalData();
  loadBedTable();
}

// ============================================================
//  UTILITY: safe text setter & XSS escape
// ============================================================
function setText(id, value) {
  const el = document.getElementById(id);
  if (el) el.textContent = value;
}

function esc(str) {
  if (str == null) return '';
  return String(str)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

// ============================================================
//  BOOT
// ============================================================
document.addEventListener('DOMContentLoaded', async () => {
  setHeaderDate();
  initNavigation();

  // Hospital must load first — HOSPITAL_ID is needed by loadCounts + loadDrivers
  await loadHospitalData();

  // Load everything else in parallel
  await Promise.all([loadCounts(), loadDrivers(), loadPatients(), loadBedTable()]);
});
