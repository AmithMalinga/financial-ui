import React, { useState } from "react";
// Icon library for nicer icons
import { HiChartBar, HiHeart, HiPieChart, HiClock, HiExclamationCircle, HiClipboardList } from 'react-icons/hi';

const PRIMARY_COLOR = '#2563EB';
const ACCENT_COLOR = '#9333EA';

const styles = {
  container: {
    minHeight: '100vh',
    background: '#FFFFFF',
    padding: '32px 16px'
  },
  maxWidth: {
    maxWidth: '1280px',
    margin: '0 auto'
  },
  header: {
    textAlign: 'center',
    marginBottom: '48px'
  },
  headerFlex: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: '16px'
  },
  title: {
    fontSize: '36px',
    fontWeight: 'bold',
    color: '#111827',
    margin: 0
  },
  subtitle: {
    fontSize: '18px',
    color: '#6B7280',
    margin: 0
  },
  card: {
    background: 'white',
    borderRadius: '6px',
    border: '1px solid #E6E7EA',
    padding: '20px',
    marginBottom: '20px'
  },
  sectionTitle: {
    fontSize: '20px',
    fontWeight: '600',
    color: '#1F2937',
    marginBottom: '16px',
    display: 'flex',
    alignItems: 'center'
  },
  grid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
    gap: '24px'
  },
  inputGroup: {
    marginBottom: '24px'
  },
  label: {
    display: 'block',
    fontSize: '14px',
    fontWeight: '500',
    color: '#374151',
    marginBottom: '8px'
  },
  input: {
    width: '100%',
    padding: '10px 12px',
    border: '1px solid #D1D5DB',
    borderRadius: '6px',
    fontSize: '15px',
    transition: 'all 0.2s',
    boxSizing: 'border-box'
  },
  button: {
    width: '100%',
    background: `linear-gradient(135deg, ${PRIMARY_COLOR} 0%, ${ACCENT_COLOR} 100%)`,
    color: 'white',
    fontWeight: '600',
    padding: '14px 20px',
    borderRadius: '8px',
    border: 'none',
    cursor: 'pointer',
    fontSize: '15px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    transition: 'all 0.18s',
    boxShadow: '0 8px 20px rgba(37,99,235,0.08)'
  },
  buttonDisabled: {
    opacity: 0.5,
    cursor: 'not-allowed'
  },
  error: {
    marginTop: '24px',
    background: '#FEF2F2',
    border: '1px solid #FCA5A5',
    borderRadius: '8px',
    padding: '16px',
    display: 'flex',
    alignItems: 'flex-start'
  },
  errorText: {
    color: '#991B1B',
    margin: 0
  },
  scoreCard: {
    borderRadius: '10px',
    boxShadow: '0 10px 18px rgba(15,23,42,0.04)',
    padding: '20px',
    marginBottom: '16px',
    border: '1px solid #E6E7EA'
  },
  scoreFlex: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    flexWrap: 'wrap',
    gap: '16px'
  },
  scoreNumber: {
    fontSize: '60px',
    fontWeight: 'bold',
    textAlign: 'center'
  },
  scoreLabel: {
    color: '#6B7280',
    fontWeight: '500',
    textAlign: 'center'
  },
  statCard: {
    padding: '16px',
    borderRadius: '8px',
    marginBottom: '12px'
  },
  statLabel: {
    fontSize: '14px',
    fontWeight: '500',
    marginBottom: '4px'
  },
  statValue: {
    fontSize: '24px',
    fontWeight: 'bold'
  },
  statExtra: {
    fontSize: '12px',
    marginTop: '4px'
  },
  allocationCard: {
    border: '1px solid #E5E7EB',
    borderRadius: '8px',
    padding: '16px',
    transition: 'box-shadow 0.18s'
  },
  progressBar: {
    marginTop: '8px',
    background: '#E5E7EB',
    borderRadius: '9999px',
    height: '8px',
    overflow: 'hidden'
  },
  progressFill: {
    height: '100%',
    background: 'linear-gradient(90deg, #3B82F6 0%, #9333EA 100%)',
    transition: 'width 0.5s'
  },
  table: {
    width: '100%',
    borderCollapse: 'collapse'
  },
  th: {
    textAlign: 'left',
    padding: '12px 16px',
    color: '#374151',
    fontWeight: '600',
    borderBottom: '2px solid #E5E7EB'
  },
  td: {
    padding: '16px',
    color: '#374151',
    borderBottom: '1px solid #F3F4F6'
  },
  badge: {
    padding: '4px 12px',
    borderRadius: '9999px',
    fontSize: '14px',
    fontWeight: '500',
    display: 'inline-block'
  },
  recommendationCard: {
    borderLeft: '4px solid',
    padding: '20px',
    borderRadius: '8px',
    marginBottom: '16px'
  }
};

// Simple PieChart component (SVG)
const PieChart = ({items = [], size = 200, innerRadius = 50}) => {
  const total = items.reduce((s, it) => s + (it.amount || 0), 0) || 1;
  let cum = 0;
  const cx = size/2; const cy = size/2; const r = size/2 - 2;
  const colors = ['#6366f1', '#06b6d4', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];

  const paths = items.map((it, idx) => {
    const start = (cum/total) * 2 * Math.PI;
    cum += (it.amount || 0);
    const end = (cum/total) * 2 * Math.PI;
    const large = end - start > Math.PI ? 1 : 0;
    const x1 = cx + r * Math.cos(start - Math.PI/2);
    const y1 = cy + r * Math.sin(start - Math.PI/2);
    const x2 = cx + r * Math.cos(end - Math.PI/2);
    const y2 = cy + r * Math.sin(end - Math.PI/2);
    const d = `M ${cx} ${cy} L ${x1} ${y1} A ${r} ${r} 0 ${large} 1 ${x2} ${y2} Z`;
    return <path key={idx} d={d} fill={colors[idx % colors.length]} stroke="#fff" strokeWidth="1" />;
  });

  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} className="pie-chart">
      {paths}
      <circle cx={cx} cy={cy} r={innerRadius} fill="#fff" />
    </svg>
  );
};

// Timeline visualization — responsive, shows ages as markers on a horizontal axis
  const TimelineVisual = ({timelines = [], currentAge = 25}) => {
    if (!timelines || timelines.length === 0) return null;
    // Defensive: coerce all ages to numbers, fallback to 0 if not valid
    const ages = timelines.map(t => {
      const n = Number(t.age_at_fi);
      return !isNaN(n) && isFinite(n) ? n : 0;
    });
    const minAge = Math.min(currentAge, ...ages) - 1;
    const maxAge = Math.max(...ages) + 1;
    const WIDTH = 1100; const HEIGHT = 110;
    const scale = (age) => 20 + ((age - minAge) / (maxAge - minAge)) * (WIDTH - 40);

    return (
      <div style={{padding:8, display:'flex', justifyContent:'center'}}>
        <svg width="100%" height={HEIGHT} viewBox={`0 0 ${WIDTH} ${HEIGHT}`} style={{maxWidth: '100%'}} preserveAspectRatio="xMidYMid meet">
          <line x1={20} y1={HEIGHT/2} x2={WIDTH-20} y2={HEIGHT/2} stroke="#c9cbd2ff" strokeWidth={2} />
          {Array.from({length:6}).map((_,i)=>{
            const age = Math.round(minAge + (i/5)*(maxAge-minAge));
            const x = scale(age);
            return (
              <g key={i}>
                <line x1={x} y1={HEIGHT/2-6} x2={x} y2={HEIGHT/2+6} stroke="#E6E7EA" />
                <text x={x} y={HEIGHT/2+20} fontSize={12} fill="#374151" textAnchor="middle">{age}</text>
              </g>
            )
          })}
          {timelines.map((t, idx) => {
            // Defensive: coerce age_at_fi to number for calculations and display
            const ageAtFiNum = Number(t.age_at_fi);
            const x = scale(!isNaN(ageAtFiNum) && isFinite(ageAtFiNum) ? ageAtFiNum : 0);
            // Balanced (ROI 12-16) is now green, others unchanged
            let color = '#06b6d4'; // Conservative
            let isBalanced = false;
            if (t.roi >= 16) color = '#ef4444'; // Aggressive
            else if (t.roi >= 12) { color = '#10B981'; isBalanced = true; } // Balanced = green
            // Defensive: display age as number with 1 decimal, fallback to 'N/A'
            const ageAtFiLabel = !isNaN(ageAtFiNum) && isFinite(ageAtFiNum) ? ageAtFiNum.toFixed(1) : 'N/A';
            return (
              <g key={idx}>
                {isBalanced ? (
                  <circle cx={x} cy={HEIGHT/2} r={13} fill="none" stroke="#10B981" strokeWidth={4} />
                ) : null}
                <circle cx={x} cy={HEIGHT/2} r={7} fill={color} />
                <text x={x} y={HEIGHT/2-14} fontSize={11} fill="#0f172a" textAnchor="middle">{t.roi}%</text>
                <text x={x} y={HEIGHT/2+34} fontSize={11} fill="#374151" textAnchor="middle">Age {ageAtFiLabel}</text>
              </g>
            )
          })}
        </svg>
      </div>
    )
  }

// Small SVG icons (no external deps)
const IconStats = ({size=18, color='#111827'}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style={{marginRight:8}}>
    <rect x="3" y="3" width="6" height="18" rx="1" fill={color} />
    <rect x="9" y="10" width="6" height="11" rx="1" fill="#93C5FD" />
    <rect x="15" y="6" width="6" height="15" rx="1" fill="#C7B4FF" />
  </svg>
);

const IconHealth = ({size=18, color=PRIMARY_COLOR}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style={{marginRight:8}}>
    <path d="M12 21s8-4.5 8-10a6 6 0 0 0-12 0c0 5.5 4 10 4 10z" fill={color} />
    <path d="M9 11l2 2 4-4" stroke="#fff" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

const IconAllocation = ({size=18, color='#10B981'}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style={{marginRight:8}}>
    <circle cx="12" cy="12" r="10" fill="#F3F4F6" />
    <path d="M12 2a10 10 0 0 1 6.32 18.32L12 12V2z" fill={color} />
  </svg>
);

// New allocation/chart icon (pie + bar) for Monthly Allocation Plan
const IconAllocationChart = ({size=18, color='#6366f1'}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style={{marginRight:8}}>
    <circle cx="10" cy="10" r="6" fill="#F3F4F6" />
    <path d="M10 4a6 6 0 0 1 6 6h-6V4z" fill="#6366f1" />
    <rect x="16" y="6" width="6" height="12" rx="1" fill="#06b6d4" transform="translate(-2 0)" />
  </svg>
);

const IconTimeline = ({size=18, color='#6B7280'}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style={{marginRight:8}}>
    <path d="M3 12h4v6H3z" fill="#E5E7EB" />
    <path d="M9 8h4v10H9z" fill="#93C5FD" />
    <path d="M15 4h4v14h-4z" fill="#FECACA" />
  </svg>
);

const IconRecommend = ({size=18, color='#111827'}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style={{marginRight:8}}>
    <circle cx="12" cy="12" r="10" fill="#FEF3C7" />
    <path d="M9 12l2 2 4-4" stroke="#92400E" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

const IconWarning = ({size=18, color='#DC2626'}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style={{marginRight:8}}>
    <path d="M12 2l10 18H2L12 2z" fill={color} />
    <path d="M12 8v6" stroke="#fff" strokeWidth="1.5" strokeLinecap="round" />
    <path d="M12 16h.01" stroke="#fff" strokeWidth="1.5" strokeLinecap="round" />
  </svg>
);

// Ring progress for creative health score
const RingProgress = ({percent=65, size=96, stroke=10, color=PRIMARY_COLOR}) => {
  const radius = (size - stroke) / 2;
  const c = 2 * Math.PI * radius;
  const dash = (percent/100) * c;
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{display:'block'}}>
      <g transform={`translate(${size/2},${size/2})`}>
        <circle r={radius} fill="#F8FAFC" stroke="#F1F5F9" strokeWidth={stroke} />
        <circle r={radius} fill="transparent" stroke={color} strokeWidth={stroke} strokeLinecap="round"
          strokeDasharray={`${dash} ${c-dash}`} strokeDashoffset={-c*0.25} transform="rotate(-90)" />
        <text x="0" y="6" fontSize="20" fontWeight="700" textAnchor="middle" fill="#0F172A">{percent}</text>
        <text x="0" y="26" fontSize="11" textAnchor="middle" fill="#6B7280">/100</text>
      </g>
    </svg>
  );
};

const FinancialAdvisor = () => {
  const [formData, setFormData] = useState({
    age: 25,
    income: 100000,
    expenses: 60000,
    debt: 200000,
    debt_critical: "no",
    emergency: 150000,
    savings: 200000,
    investments: 500000
  });

  const [report, setReport] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };

  const handleSubmit = async () => {
    setLoading(true);
    setError(null);

    try {
      const params = new URLSearchParams({
        age: formData.age,
        income: formData.income,
        expenses: formData.expenses,
        debt: formData.debt,
        debt_critical: formData.debt_critical,
        emergency: formData.emergency,
        savings: formData.savings,
        investments: formData.investments
      });

  // Use relative path so CRA dev server proxy (configured in package.json) forwards the request to the API
  // This avoids CORS errors during development.
  const base = process.env.REACT_APP_API_URL || '';
  const url = base ? `${base.replace(/\/$/, '')}/financial_advisor?${params}` : `/financial_advisor?${params}`;
      const response = await fetch(url, { mode: base ? 'cors' : 'same-origin' });

      if (!response.ok) throw new Error("Failed to fetch report");

      // Some backends may accidentally prepend header-like text into the response body
      // (e.g. "Content-type: application/json;charset=UTF-8{"...}). To be robust, read
      // the raw text and attempt JSON.parse; if that fails, strip any prefix up to the
      // first JSON token ('{' or '[') and try again.
      const text = await response.text();
      let data;
      try {
        data = JSON.parse(text);
      } catch (parseErr) {
        // find first JSON-start character
        const idxObj = text.indexOf('{') === -1 ? Infinity : text.indexOf('{');
        const idxArr = text.indexOf('[') === -1 ? Infinity : text.indexOf('[');
        const firstIdx = Math.min(idxObj, idxArr);
        if (firstIdx !== Infinity) {
          const candidate = text.slice(firstIdx);
          try {
            data = JSON.parse(candidate);
            console.warn('Parsed JSON after stripping prefix. Original response had unexpected prefix.');
          } catch (e2) {
            console.error('Failed to parse JSON response after stripping prefix:', e2, '\nResponse text:', text);
            throw new Error('Invalid JSON received from API');
          }
        } else {
          console.error('No JSON object/array found in response text:', text);
          throw new Error('Invalid JSON received from API');
        }
      }

      setReport(data);
    } catch (err) {
      setError(err.message || "Error connecting to API. Please ensure the server is running.");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-LK', {
      style: 'currency',
      currency: 'LKR',
      maximumFractionDigits: 0
    }).format(amount);
  };

  const getScoreColor = (score) => {
    if (score >= 80) return "#059669";
    if (score >= 60) return "#2563EB";
    if (score >= 40) return "#D97706";
    return "#DC2626";
  };

  const getScoreBg = (score) => {
    if (score >= 80) return "#D1FAE5";
    if (score >= 60) return "#DBEAFE";
    if (score >= 40) return "#FEF3C7";
    return "#FEE2E2";
  };

  // Compute the index of the "ideal" FI timeline (fewest years_to_fi)
  let idealTimelineIndex = -1;
  if (report && report.fi_timelines && report.fi_timelines.length > 0) {
    idealTimelineIndex = report.fi_timelines.reduce((bestIdx, t, i, arr) => {
      return t.years_to_fi < arr[bestIdx].years_to_fi ? i : bestIdx;
    }, 0);
  }

  return (
    <div style={styles.container}>
      <div style={styles.maxWidth}>
        <div style={styles.header}>
          <div style={styles.headerFlex}>
            <h1 style={styles.title}>Financial Freedom Calculator</h1>
          </div>
          <p style={styles.subtitle}>A simple calculator to plan and reach financial freedom sooner | Enter your numbers and generate a personalized plan.</p>
        </div>

        <div style={styles.card}>
          <h2 style={styles.sectionTitle}>Your Current Financial Information</h2>
          
          <div style={styles.grid}>
            <div style={styles.inputGroup}>
              <label style={styles.label}>Age</label>
              <input
                type="number"
                name="age"
                value={formData.age}
                onChange={handleChange}
                style={styles.input}
              />
            </div>

            <div style={styles.inputGroup}>
              <label style={styles.label}>Monthly Income (LKR)</label>
              <input
                type="number"
                name="income"
                value={formData.income}
                onChange={handleChange}
                style={styles.input}
              />
            </div>

            <div style={styles.inputGroup}>
              <label style={styles.label}>Monthly Expenses (LKR)</label>
              <input
                type="number"
                name="expenses"
                value={formData.expenses}
                onChange={handleChange}
                style={styles.input}
              />
            </div>

            <div style={styles.inputGroup}>
              <label style={styles.label}>Total Debt (LKR)</label>
              <input
                type="number"
                name="debt"
                value={formData.debt}
                onChange={handleChange}
                style={styles.input}
              />
            </div>

            <div style={styles.inputGroup}>
              <label style={styles.label}>Is Debt Critical?</label>
              <select
                name="debt_critical"
                value={formData.debt_critical}
                onChange={handleChange}
                style={styles.input}
              >
                <option value="no">No</option>
                <option value="yes">Yes</option>
              </select>
            </div>

            <div style={styles.inputGroup}>
              <label style={styles.label}>Emergency Fund (LKR)</label>
              <input
                type="number"
                name="emergency"
                value={formData.emergency}
                onChange={handleChange}
                style={styles.input}
              />
            </div>

            <div style={styles.inputGroup}>
              <label style={styles.label}>Savings (LKR)</label>
              <input
                type="number"
                name="savings"
                value={formData.savings}
                onChange={handleChange}
                style={styles.input}
              />
            </div>

            <div style={styles.inputGroup}>
              <label style={styles.label}>Investments (LKR)</label>
              <input
                type="number"
                name="investments"
                value={formData.investments}
                onChange={handleChange}
                style={styles.input}
              />
            </div>
          </div>

          <button
            onClick={handleSubmit}
            disabled={loading}
            style={{...styles.button, ...(loading ? styles.buttonDisabled : {})}}
          >
                {loading ? (
              <>
                <div style={{
                  border: '2px solid white',
                  borderTop: '2px solid transparent',
                  borderRadius: '50%',
                  width: '20px',
                  height: '20px',
                  animation: 'spin 1s linear infinite',
                  marginRight: '8px'
                }}></div>
                Generating Plan...
              </>
                ) : (
                  <>Generate Your Plan</>
                )}
          </button>

          {error && (
            <div style={styles.error}>
              <HiExclamationCircle size={20} style={{marginRight:8}} color="#DC2626" />
              <p style={styles.errorText}>{error}</p>
            </div>
          )}
        </div>

        {report && (
          <div>
            {/* Row 2: Current Financial State */}
            <div style={styles.card}>
              <h2 style={styles.sectionTitle}><IconStats />Current Financial State</h2>
              <div style={styles.grid}>
                <div style={{...styles.statCard, border: '1px solid #E6E7EA', background: 'linear-gradient(90deg,#EFF6FF,#EEF2FF)'}}>
                  <div style={{...styles.statLabel, color: '#1E40AF'}}>Monthly Income</div>
                  <div style={{...styles.statValue, color: '#111827'}}>{formatCurrency(report.monthly_income)}</div>
                </div>

                <div style={{...styles.statCard, border: '1px solid #E6E7EA', background: 'linear-gradient(90deg,#F5F3FF,#FBF7FF)'}}>
                  <div style={{...styles.statLabel, color: '#6B21A8'}}>Monthly Expenses</div>
                  <div style={{...styles.statValue, color: '#111827'}}>{formatCurrency(report.monthly_expenses)}</div>
                </div>

                <div style={{...styles.statCard, border: '1px solid #E6E7EA', background: 'linear-gradient(90deg,#ECFDF5,#F0FDF4)'}}>
                  <div style={{...styles.statLabel, color: '#065F46'}}>Monthly Savings</div>
                  <div style={{...styles.statValue, color: '#111827'}}>{formatCurrency(report.monthly_savings)}</div>
                  <div style={{...styles.statExtra, color: '#6B7280'}}>
                    {(typeof report.monthly_income === 'number' && report.monthly_income > 0 && typeof report.monthly_savings === 'number') ? ((report.monthly_savings / report.monthly_income) * 100).toFixed(1) + '% savings rate' : 'N/A'}
                  </div>
                </div>

                <div style={{...styles.statCard, border: '1px solid #E6E7EA', background: 'linear-gradient(90deg,#FFF7ED,#FFFBF0)'}}>
                  <div style={{...styles.statLabel, color: '#92400E'}}>Total Assets</div>
                  <div style={{...styles.statValue, color: '#111827'}}>{formatCurrency(report.total_assets)}</div>
                </div>
              </div>
            </div>

            {/* Row 3: two-column grid - Health Score (left) and Allocation (right) with equal sizing */}
              <div style={{display:'grid', gridTemplateColumns: '1fr 1fr', gap:16, marginBottom:16, alignItems:'start'}}>
              <div style={{minWidth:280, display:'flex'}}>
                <div style={{...styles.card, display:'flex', flexDirection:'column', flex:1, minHeight:340}}>
                  <h2 style={styles.sectionTitle}><IconHealth />Financial Health Score</h2>
                  <div style={{display:'flex',alignItems:'center',gap:80, flex:1}}>
                    <div style={{width:110}}>
                      <RingProgress percent={report.financial_health_score} size={160} stroke={16} />
                    </div>
                    <div style={{flex:1, display:'flex', flexDirection:'column'}}>
                      {/* <div style={{color:'#6B7280',fontWeight:600}}>Overall assessment</div> */}
                      <div style={{marginTop:8,color:'#374151'}}>
                        {/* Render score reasons as bullet points for clarity */}
                        {report.score_reasons ? (
                          <ul style={{margin: '8px 0 0 18px', padding:0, color:'#374151', fontSize:14, lineHeight:1.5}}>
                            {report.score_reasons.split(/\r?\n/).map((line, i) => {
                              const t = line.trim();
                              return t ? <li key={i} style={{marginBottom:6, lineHeight:1.4}}>{t}</li> : null;
                            })}
                          </ul>
                        ) : null}
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div style={{minWidth:280, display:'flex'}}>
                <div style={{...styles.card, display:'flex', flexDirection:'column', flex:1, minHeight:340}}>
                  <h2 style={styles.sectionTitle}><IconAllocationChart />Monthly Allocation Plan</h2>
                  {(() => {
                    // Pie chart colors (must match PieChart component)
                    const pieColors = ['#6366f1', '#06b6d4', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];
                    // Add consumption (expenses) as a portion in the pie chart
                    const breakdown = Array.isArray(report.monthly_breakdown) ? [...report.monthly_breakdown] : [];
                    const expenses = typeof report.monthly_expenses === 'number' ? report.monthly_expenses : Number(report.monthly_expenses);
                    if (!isNaN(expenses) && expenses > 0) {
                      breakdown.unshift({
                        category: 'Consumption',
                        amount: expenses,
                        percent: report.monthly_income && expenses ? ((expenses / report.monthly_income) * 100).toFixed(1) : null
                      });
                    }
                    return (
                      <div style={{display:'flex',alignItems:'center',gap:24, flex:1}}>
                        <PieChart items={breakdown} size={160} innerRadius={46} />
                        <div style={{flex:1}}>
                          {breakdown.map((it, idx) => (
                            <div key={idx} style={{display:'grid', gridTemplateColumns: '1fr 120px', alignItems:'center', marginBottom:8}}>
                              <div style={{display:'flex',flexDirection:'column'}}>
                                <div style={{display:'flex',alignItems:'center',gap:8}}>
                                  <span style={{display:'inline-block',width:16,height:16,borderRadius:4,background: pieColors[idx % pieColors.length],border:'1px solid #e5e7eb'}}></span>
                                  <span style={{fontWeight:700,color:'#374151'}}>{it.category}</span>
                                </div>
                                <div style={{fontSize:12,color:'#6B7280'}}>{(it.percent !== null && it.percent !== undefined) ? `${it.percent}% of income` : 'N/A'}</div>
                              </div>
                              <div style={{color:'#374151',fontWeight:600,textAlign:'right'}}>{(it.amount !== null && it.amount !== undefined && !isNaN(Number(it.amount))) ? formatCurrency(Number(it.amount)) : 'N/A'}</div>
                            </div>
                          ))}
                        </div>
                      </div>
                    );
                  })()}
                </div>
              </div>
            </div>

            <div style={styles.card}>
              <h2 style={styles.sectionTitle}><IconTimeline />Path to Financial Independence</h2>

              <TimelineVisual timelines={report.fi_timelines} currentAge={report.age || formData.age} />

                <div style={{marginTop:8}}>
                  <div style={{display:'flex',gap:12,alignItems:'center',marginBottom:8,fontSize:13,color:'#374151'}}>
                    <div style={{display:'flex',alignItems:'center',gap:8}}><div style={{width:10,height:10,background:'#06b6d4',borderRadius:3}} />Conservative (lower ROI)</div>
                    <div style={{display:'flex',alignItems:'center',gap:8}}><div style={{width:10,height:10,background:'#10B981',borderRadius:3, border:'2px solid #10B981'}} />Balanced</div>
                    <div style={{display:'flex',alignItems:'center',gap:8}}><div style={{width:10,height:10,background:'#ef4444',borderRadius:3}} />Aggressive (higher ROI)</div>
                  </div>

                  <div style={{overflowX: 'auto'}}>
                  <table style={styles.table}>
                    <thead>
                      <tr>
                        <th style={styles.th}>Annual Return (ROI %)</th>
                        <th style={styles.th}>Years to Financial Independence</th>
                        <th style={styles.th}>Age at Financial Independence</th>
                        <th style={styles.th}>Suggested Strategy</th>
                        <th style={styles.th}>Risk Level / Profitability</th>
                      </tr>
                    </thead>
                    <tbody>
                    {(report.fi_timelines || []).map((timeline, idx) => {
                      let strategy = "Conservative";
                      let badgeStyle = {background: '#DBEAFE', color: '#1E40AF', borderRadius: 8, fontWeight: 600, fontSize: 14, padding: '4px 12px', display: 'inline-block'};
                      if (timeline.roi >= 12 && timeline.roi < 16) {
                        strategy = "Balanced";
                        badgeStyle = {background: '#D1FAE5', color: '#065F46', borderRadius: 8, fontWeight: 600, fontSize: 14, padding: '4px 12px', display: 'inline-block'}; // green for balanced
                      } else if (timeline.roi >= 16) {
                        strategy = "Aggressive";
                        badgeStyle = {background: '#FEE2E2', color: '#991B1B', borderRadius: 8, fontWeight: 600, fontSize: 14, padding: '4px 12px', display: 'inline-block'};
                      }

                      // derive risk and profit labels from ROI
                      let riskLabel = 'Low';
                      let riskBadgeStyle = {background: '#D1FAE5', color: '#065F46', borderRadius: 8, fontWeight: 600, fontSize: 14, padding: '4px 12px', display: 'inline-block'};
                      let profitLabel = 'Lower expected returns';
                      if (timeline.roi >= 16) {
                        riskLabel = 'High';
                        riskBadgeStyle = {background: '#FEE2E2', color: '#991B1B', borderRadius: 8, fontWeight: 600, fontSize: 14, padding: '4px 12px', display: 'inline-block'};
                        profitLabel = 'High expected returns';
                      } else if (timeline.roi >= 12) {
                        riskLabel = 'Medium';
                        riskBadgeStyle = {background: '#D1FAE5', color: '#10B981', borderRadius: 8, fontWeight: 600, fontSize: 14, padding: '4px 12px', display: 'inline-block'}; // green border for medium
                        profitLabel = 'Moderate expected returns';
                      }

                      // Only highlight as 'Ideal' if strategy is 'Balanced' and risk is 'Medium' or 'Low'
                      const isIdeal = idx === idealTimelineIndex && (strategy === 'Balanced') && (riskLabel === 'Medium' || riskLabel === 'Low');
                      const rowStyle = {
                        transition: 'background 0.2s',
                        ...(isIdeal ? {background: '#FFFBEB', borderLeft: `4px solid ${PRIMARY_COLOR}`, boxShadow: 'inset 0 0 0 1px rgba(16,185,129,0.03)'} : {})
                      };
                      // Defensive: handle empty string/null, fallback to 'N/A'. Only show positive values.
                      let yearsToFi = 'N/A';
                      if (timeline.years_to_fi !== null && timeline.years_to_fi !== undefined && timeline.years_to_fi !== '') {
                        const n = Number(timeline.years_to_fi);
                        yearsToFi = (!isNaN(n) && isFinite(n) && n > 0) ? n.toFixed(1) : 'N/A';
                      }
                      let ageAtFi = 'N/A';
                      if (timeline.age_at_fi !== null && timeline.age_at_fi !== undefined && timeline.age_at_fi !== '') {
                        const n = Number(timeline.age_at_fi);
                        ageAtFi = (!isNaN(n) && isFinite(n) && n > 0) ? n.toFixed(1) : 'N/A';
                      }

                      return (
                        <tr key={idx} style={rowStyle}>
                          <td style={styles.td}>
                            <span style={{fontWeight: '600', color: '#111827'}}>{timeline.roi}%</span>
                          </td>
                          <td style={styles.td}>{yearsToFi} years</td>
                          <td style={styles.td}>{ageAtFi} years</td>
                          <td style={styles.td}>
                            <div style={{display:'flex',alignItems:'center',gap:8}}>
                              <span style={badgeStyle}>
                                {strategy}
                              </span>
                              {isIdeal ? (
                                <span style={{fontSize:12,fontWeight:700,background:'#10B981',color:'#ffffff',padding:'4px 8px',borderRadius:6}}>Ideal</span>
                              ) : null}
                            </div>
                          </td>
                          <td style={styles.td}>
                            <div style={{display:'flex',flexDirection:'column',alignItems:'flex-start',gap:4}}>
                              <span style={riskBadgeStyle}>{riskLabel} risk</span>
                              <div style={{fontSize:12,color:'#374151'}}>{profitLabel}</div>
                            </div>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
                </div>
              </div>
            </div>

            <div style={styles.card}>
              {/* Investment Categories Section with modern card design */}
              <div style={{
                background: 'linear-gradient(135deg, #F8FAFC 0%, #F1F5F9 100%)',
                border: '1px solid #E2E8F0',
                borderRadius: '12px',
                padding: '24px',
                marginBottom: '32px'
              }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                  marginBottom: '20px'
                }}>
                  <div style={{
                    width: '40px',
                    height: '40px',
                    background: 'linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%)',
                    borderRadius: '10px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center'
                  }}>
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M12 2L2 7l10 5 10-5-10-5z" fill="#fff" opacity="0.8"/>
                      <path d="M2 17l10 5 10-5M2 12l10 5 10-5" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                    </svg>
                  </div>
                  <div>
                    <h3 style={{
                      fontWeight: '700',
                      fontSize: '18px',
                      color: '#0F172A',
                      margin: 0
                    }}>Suggested Investment Categories for your portfolio</h3>
                    <p style={{
                      fontSize: '14px',
                      color: '#64748B',
                      margin: '2px 0 0 0'
                    }}>Diversify your portfolio across these recommended areas</p>
                  </div>
                </div>
                <div style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))',
                  gap: '12px'
                }}>
                  {['Renewable energy', 'Agriculture', 'Unit trusts', 'Personal development', 'Gold', 'Silver', 'Treasury bonds', 'Fixed deposits'].map((item, i) => (
                    <div key={i} style={{
                      background: '#FFFFFF',
                      border: '1px solid #E2E8F0',
                      borderRadius: '8px',
                      padding: '12px 16px',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '10px',
                      transition: 'all 0.2s',
                      cursor: 'default'
                    }} className="investment-category-chip">
                      <div style={{
                        width: '8px',
                        height: '8px',
                        borderRadius: '50%',
                        background: 'linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%)'
                      }}></div>
                      <span style={{
                        fontSize: '14px',
                        fontWeight: '500',
                        color: '#334155'
                      }}>{item}</span>
                    </div>
                  ))}
                </div>
              </div>

              <h3>Personalized Recommendations: </h3>

              {/* Action Items Section - combined into a single professional card */}
              <div style={{marginBottom: '16px'}}>
                <h3 style={{
                  fontSize: '16px',
                  fontWeight: '700',
                  color: '#0F172A',
                  marginBottom: '12px',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px'
                }}>
          
                </h3>
              </div>

              <div style={{background: '#FFFFFF', border: '1px solid #E6E7EA', borderRadius: 12, padding: 20, marginBottom: 16}}>
                <div style={{display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12}}>
                  <div>
                    {/* <div style={{fontSize:14, color:'#6B7280'}}>Priority action list — consolidated</div> */}
                    {/* <div style={{fontWeight:700, color:'#0F172A'}}>Recommended next steps to improve your financial plan</div> */}
                  </div>
                </div>

                {(!report.recommendations || report.recommendations.length === 0) ? (
                  <div style={{color:'#64748B'}}>No action items available.</div>
                ) : (
                  <ol style={{margin:0, paddingLeft: 18}}>
                    {report.recommendations.map((rec, i) => (
                      <li key={i} style={{marginBottom:12}}>
                        <div style={{display:'flex', justifyContent:'space-between', gap:12}}>
                          <div style={{flex:1}}>
                            <div style={{fontWeight:700, color:'#0F172A', marginBottom:6}}>{rec.title}</div>
                            {rec.detail ? (
                              <div style={{color:'#475569', lineHeight:1.6}}>
                                {rec.detail.split(/\r?\n/).map((line, j) => line.trim() ? <div key={j} style={{marginBottom:6}}>{line}</div> : null)}
                              </div>
                            ) : null}
                          </div>
                          <div style={{minWidth:120, textAlign:'right'}}>
                            <div style={{display:'inline-block', padding:'6px 10px', borderRadius:8, fontWeight:700, fontSize:12, background: rec.priority === 'high' ? '#FEE2E2' : '#DBEAFE', color: rec.priority === 'high' ? '#991B1B' : '#1E40AF', border: `1px solid ${rec.priority === 'high' ? '#FCA5A5' : '#93C5FD'}`}}>
                              {rec.priority ? rec.priority.toUpperCase() : 'PRIORITY'}
                            </div>
                          </div>
                        </div>
                      </li>
                    ))}
                  </ol>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
      
      <style>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        input:focus, select:focus {
          outline: none;
          border-color: #3B82F6;
          box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }
        button:hover:not(:disabled) {
          transform: translateY(-2px);
          box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2);
        }
        tr:hover {
          background: #F9FAFB;
        }
        .allocation-card:hover {
          box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }
      `}</style>
    </div>
  );
};

export default FinancialAdvisor;