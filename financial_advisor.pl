% ===========================
% Financial Freedom Expert System - Sri Lanka Edition
% Version: 5.5 - Fixed Server Threading Issues
% ===========================

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).

:- http_handler(root(financial_advisor), financial_advisor_handler, []).

% ------------------------------------------------------------------
% HTTP handler: receives query parameters and returns JSON report
% ------------------------------------------------------------------
financial_advisor_handler(Request) :-
    catch(
        (
            http_parameters(Request, [
                age(Age, [integer]),
                income(MonthlyIncome, [integer]),
                expenses(MonthlyExpenses, [integer]),
                debt(Debt, [integer]),
                debt_critical(DebtCriticalStr, [oneof([yes,no])]),
                emergency(EmergencyBalance, [integer]),
                savings(Savings, [integer]),
                investments(Investments, [integer])
            ]),
            (DebtCriticalStr = yes -> DebtCritical = yes ; DebtCritical = no),
            generate_financial_report_json(
                Age, MonthlyIncome, MonthlyExpenses, Debt, DebtCritical,
                EmergencyBalance, Savings, Investments, ReportDict
            ),
            reply_json_dict(ReportDict)
        ),
        Error,
        (
            message_to_string(Error, Msg),
            reply_json_dict(_{error: Msg}, [status(400)])
        )
    ).

% ------------------------------------------------------------------
% Enhanced JSON wrapper to generate comprehensive report
% ------------------------------------------------------------------
generate_financial_report_json(Age, MonthlyIncome, MonthlyExpenses, Debt, DebtCritical,
                               EmergencyBalance, Savings, Investments, Dict) :-
    generate_financial_report(Age, MonthlyIncome, MonthlyExpenses, Debt, DebtCritical,
                              EmergencyBalance, Savings, Investments, ReportStr),
    
    generate_financial_report_markdown(Age, MonthlyIncome, MonthlyExpenses, Debt, DebtCritical,
                                       EmergencyBalance, Savings, Investments, ReportMd),
    
    calculate_financial_health_score(MonthlyIncome, MonthlyExpenses, Debt,
                                     EmergencyBalance, Savings, Investments,
                                     HealthScore, ScoreReasons),
    
    MonthlySavings is MonthlyIncome - MonthlyExpenses,
    TotalAssets is EmergencyBalance + Savings + Investments,
    
    income_plan(MonthlyIncome, Plan),
    calculate_allocation(MonthlyIncome, MonthlyExpenses, DebtCritical, Plan, Allocation),
    
    generate_monthly_breakdown(MonthlySavings, DebtCritical, Plan, MonthlyBreakdown),
    generate_recommendations(HealthScore, DebtCritical, EmergencyBalance, MonthlyExpenses, 
                            Debt, MonthlyIncome, Plan, Recommendations),
    
    ROI_Rates = [8, 12, 16, 20, 24],
    Allocation = allocation(InvAmount, _, _, _),
    calculate_all_timelines_json(Age, MonthlyExpenses, TotalAssets, InvAmount, ROI_Rates, Timelines),
    
    get_time(Timestamp),
    format_time(atom(GeneratedAt), '%Y-%m-%dT%H:%M:%SZ', Timestamp),
    
    (DebtCritical = yes -> DebtCriticalStr = "yes" ; DebtCriticalStr = "no"),
    
    Dict = _{
        age: Age,
        monthly_income: MonthlyIncome,
        monthly_expenses: MonthlyExpenses,
        monthly_savings: MonthlySavings,
        debt: Debt,
        debt_critical: DebtCriticalStr,
        emergency_balance: EmergencyBalance,
        savings: Savings,
        investments: Investments,
        total_assets: TotalAssets,
        financial_health_score: HealthScore,
        score_reasons: ScoreReasons,
        report_text: ReportStr,
        report_markdown: ReportMd,
        recommendations: Recommendations,
        monthly_breakdown: MonthlyBreakdown,
        fi_timelines: Timelines,
        meta: _{
            generated_at: GeneratedAt,
            currency: "LKR",
            version: "5.5"
        }
    }.  

% ------------------------------------------------------------------
% Convert FI timelines to JSON-friendly structure
% ------------------------------------------------------------------
calculate_all_timelines_json(Age, MonthlyExpenses, CurrentAssets, MonthlyInv, ROIList, Timelines) :-
    findall(Timeline,
        (member(ROI, ROIList),
         calculate_fi_timeline(Age, MonthlyExpenses, CurrentAssets, MonthlyInv, ROI, Years, AgeAtFI),
         Timeline = _{roi: ROI, years_to_fi: Years, age_at_fi: AgeAtFI}
        ),
    Timelines).

% ------------------------------------------------------------------
% Generate monthly breakdown as JSON array
% ------------------------------------------------------------------
generate_monthly_breakdown(MonthlySavings, DebtCritical, Plan, Breakdown) :-
    get_percentages(Plan, DebtCritical, InvPct, DebtPct),
    Plan = plan(_, _, SavingsPct, _, _, _, _, _),
    
    InvestmentAmount is truncate((MonthlySavings * InvPct) / 100),
    DebtPayment is truncate((MonthlySavings * DebtPct) / 100),
    EmergencyAmount is truncate((MonthlySavings * SavingsPct) / 100),
    Remaining is truncate(MonthlySavings - InvestmentAmount - DebtPayment - EmergencyAmount),
    
    RemainingPct is 100 - InvPct - DebtPct - SavingsPct,
    
    Breakdown = [
        _{category: "Investments", amount: InvestmentAmount, percent: InvPct},
        _{category: "Debt Payment", amount: DebtPayment, percent: DebtPct},
        _{category: "Emergency Fund", amount: EmergencyAmount, percent: SavingsPct},
        _{category: "Flexible/Personal Dev", amount: Remaining, percent: RemainingPct}
    ].

% ------------------------------------------------------------------
% Generate recommendations based on financial situation
% ------------------------------------------------------------------
generate_recommendations(HealthScore, DebtCritical, EmergencyBalance, MonthlyExpenses,
                        Debt, MonthlyIncome, Plan, Recommendations) :-
    findall(Rec, recommendation(HealthScore, DebtCritical, EmergencyBalance, 
                                MonthlyExpenses, Debt, MonthlyIncome, Plan, Rec), Recommendations).

recommendation(_, _, EmergencyBalance, MonthlyExpenses, _, _, _, Rec) :-
    MonthlyExpenses > 0,
    EmergencyMonths is EmergencyBalance / MonthlyExpenses,
    EmergencyMonths < 6,
    Rec = _{
        title: "Emergency Fund Priority",
        detail: "Build emergency fund to 6 months of expenses before aggressive investing. This protects you from unexpected events.",
        priority: "high"
    }.

recommendation(_, yes, _, _, Debt, _, _, Rec) :-
    Debt > 0,
    Rec = _{
        title: "Debt Reduction Critical",
        detail: "Your debt level is critical. Focus on paying down high-interest debt (>15%) aggressively before increasing investments.",
        priority: "critical"
    }.

recommendation(_, _, _, _, _, _, Plan, Rec) :-
    Plan = plan(_, _, _, _, _, _, _, InvestmentOptions),
    Rec = _{
        title: "Investment Diversification",
        detail: InvestmentOptions,
        priority: "medium"
    }.

recommendation(HealthScore, _, _, _, _, _, _, Rec) :-
    HealthScore < 40,
    Rec = _{
        title: "Financial Basics",
        detail: "Focus on increasing income, reducing unnecessary expenses, and building a solid savings habit. Track every expense for 3 months.",
        priority: "high"
    }.

recommendation(HealthScore, _, _, _, _, MonthlyIncome, _, Rec) :-
    HealthScore >= 60,
    MonthlySavings is MonthlyIncome * 0.4,
    MonthlySavings > 20000,
    Rec = _{
        title: "Advanced Wealth Building",
        detail: "Consider tax-efficient investment vehicles, real estate opportunities, and potentially starting a side business to accelerate wealth building.",
        priority: "medium"
    }.

recommendation(_, _, _, _, _, _, _, Rec) :-
    Rec = _{
        title: "Financial Education",
        detail: "Continuously educate yourself on personal finance, investment strategies, and market trends. Knowledge prevents costly mistakes.",
        priority: "medium"
    }.

% ------------------------------------------------------------------
% Generate markdown-formatted report
% ------------------------------------------------------------------
generate_financial_report_markdown(Age, MonthlyIncome, MonthlyExpenses, Debt, DebtCritical,
                                   EmergencyBalance, Savings, Investments, ReportMd) :-
    calculate_financial_health_score(MonthlyIncome, MonthlyExpenses, Debt,
                                    EmergencyBalance, Savings, Investments,
                                    HealthScore, ScoreReasons),
    
    income_plan(MonthlyIncome, Plan),
    Plan = plan(IncomeCategory, _, _, _, _, _, _, InvestmentOptions),
    
    calculate_allocation(MonthlyIncome, MonthlyExpenses, DebtCritical, Plan, Allocation),
    Allocation = allocation(InvAmount, DebtAmount, EmergencyAmount, RemainingAmount),
    
    get_percentages(Plan, DebtCritical, InvPct, DebtPct),
    
    CurrentAssets is EmergencyBalance + Savings + Investments,
    MonthlySavings is MonthlyIncome - MonthlyExpenses,
    (MonthlyIncome > 0 -> SavingsRate is (MonthlySavings / MonthlyIncome) * 100 ; SavingsRate = 0),
    
    (HealthScore < 40 -> Assessment = 'NEEDS IMMEDIATE ATTENTION'
    ; HealthScore < 60 -> Assessment = 'FAIR - Building foundation'
    ; HealthScore < 80 -> Assessment = 'GOOD - On the right track'
    ; Assessment = 'EXCELLENT - Strong position'),
    
    (DebtCritical = yes -> DebtStatusText = 'CRITICAL' ; DebtStatusText = 'MANAGEABLE'),
    (DebtCritical = yes -> DebtLevelText = 'CRITICAL' ; DebtLevelText = 'Manageable'),
    
    ROI_Rates = [8, 12, 16, 20, 24],
    calculate_all_timelines_markdown(Age, MonthlyExpenses, CurrentAssets, InvAmount, ROI_Rates, TimelinesText),
    
    MonthlyIncomeInt is truncate(MonthlyIncome),
    MonthlyExpensesInt is truncate(MonthlyExpenses),
    MonthlySavingsInt is truncate(MonthlySavings),
    EmergencyBalanceInt is truncate(EmergencyBalance),
    SavingsInt is truncate(Savings),
    InvestmentsInt is truncate(Investments),
    CurrentAssetsInt is truncate(CurrentAssets),
    DebtInt is truncate(Debt),
    AnnualExpenses is truncate(MonthlyExpenses * 12),
    
    format(atom(Header), '================================================================~n        COMPREHENSIVE FINANCIAL FREEDOM REPORT~n                  (Sri Lanka - LKR)~n================================================================~n', []),
    
    format(atom(Section1), '~n================================================================~n STEP 1: YOUR FINANCIAL HEALTH SCORE~n================================================================~n~nOVERALL SCORE: ~w/100~n~n~w~n~nASSESSMENT: ~w~n', 
        [HealthScore, ScoreReasons, Assessment]),
    
    format(atom(Section2), '~n================================================================~n STEP 2: YOUR INCOME-BASED FINANCIAL PLAN~n================================================================~n~nIncome Category: ~w (Rs. ~:d per month)~nDebt Status: ~w~n~nMONTHLY BREAKDOWN (from Rs. ~:d savings):~n  - For Investments: Rs. ~:d (~w%%)~n  - For Debt Payment: Rs. ~:d (~w%%)~n  - For Emergency Fund: Rs. ~:d~n  - Flexible/Personal Dev: Rs. ~:d~n~nRECOMMENDED INVESTMENT OPTIONS:~n~w~n~nNote: Diversify across multiple options. Never put all money~nin one investment. Start with lower-risk options and gradually~nmove to higher-risk investments as you gain experience.~n',
        [IncomeCategory, MonthlyIncomeInt, DebtStatusText, MonthlySavingsInt,
         InvAmount, InvPct, DebtAmount, DebtPct, EmergencyAmount, RemainingAmount, InvestmentOptions]),
    
    format(atom(Section3), '~n================================================================~n STEP 3: YOUR CURRENT FINANCIAL STATE~n================================================================~n~nAge: ~w years~nMonthly Income: Rs. ~:d~nMonthly Expenses: Rs. ~:d~nMonthly Savings: Rs. ~:d (~1f%% savings rate)~n~nCurrent Assets:~n  - Emergency Fund: Rs. ~:d~n  - Savings: Rs. ~:d~n  - Investments: Rs. ~:d~n  - TOTAL ASSETS: Rs. ~:d~n~nDebt: Rs. ~:d (~w)~n',
        [Age, MonthlyIncomeInt, MonthlyExpensesInt, MonthlySavingsInt, SavingsRate,
         EmergencyBalanceInt, SavingsInt, InvestmentsInt, CurrentAssetsInt, DebtInt, DebtLevelText]),
    
    format(atom(Section4), '~n================================================================~n STEP 4: PATH TO FINANCIAL INDEPENDENCE~n================================================================~n~nFinancial Independence Target: Your investments generate~nRs. ~:d per month (Rs. ~:d per year) to cover your expenses.~n~nTIMELINE TO FINANCIAL INDEPENDENCE:~n(Based on monthly investment of Rs. ~:d)~n~n~w~n~nRECOMMENDATION:~n- Conservative approach (8-12%% ROI): Focus on FDs, bonds, funds~n- Balanced approach (12-16%% ROI): Mix of stocks, funds, property~n- Aggressive approach (16-24%% ROI): Stocks, business, real estate~n  (Higher risk, requires knowledge and active management)~n~nChoose a strategy that matches your risk tolerance and financial~nknowledge. Most people achieve 10-15%% average annual returns with~nbalanced diversified portfolios.~n',
        [MonthlyExpensesInt, AnnualExpenses, InvAmount, TimelinesText]),
    
    format(atom(Footer), '~n================================================================~n~nImportant Notes:~n1. Review and adjust this plan every 6 months~n2. Emergency fund must reach 6 months expenses before aggressive investing~n3. Pay high-interest debt (>15%%) before investing~n4. Never invest money you cannot afford to lose~n5. Learn before investing - education prevents costly mistakes~n6. Start small, learn, then increase investment amounts~n~n================================================================~n', []),
    
    atomic_list_concat([Header, Section1, Section2, Section3, Section4, Footer], ReportMd).

calculate_all_timelines(Age, MonthlyExpenses, CurrentAssets, MonthlyInv, ROIList, TimelinesText) :-
    calculate_timeline_strings(Age, MonthlyExpenses, CurrentAssets, MonthlyInv, ROIList, [], TimelinesList),
    atomic_list_concat(TimelinesList, '\n', TimelinesText).

calculate_timeline_strings(_, _, _, _, [], Acc, Result) :-
    reverse(Acc, Result).

calculate_timeline_strings(Age, MonthlyExpenses, CurrentAssets, MonthlyInv, [ROI|Rest], Acc, Result) :-
    calculate_fi_timeline(Age, MonthlyExpenses, CurrentAssets, MonthlyInv, ROI, Years, AgeAtFI),
    (Years = impossible ->
        format(atom(Line), '  ~w%% ROI: IMPOSSIBLE with current savings rate', [ROI])
    ; Years = over_50 ->
        format(atom(Line), '  ~w%% ROI: More than 50 years', [ROI])
    ; Years = 0 ->
        format(atom(Line), '  ~w%% ROI: ALREADY ACHIEVED! You are financially independent!', [ROI])
    ;
        format(atom(Line), '  ~w%% ROI: ~w years (Age ~w)', [ROI, Years, AgeAtFI])
    ),
    calculate_timeline_strings(Age, MonthlyExpenses, CurrentAssets, MonthlyInv, Rest, [Line|Acc], Result).

% ===========================
% COMMAND LINE INTERFACE
% ===========================

start :-
    nl, nl,
    write('================================================================'), nl,
    write('   ADVANCED FINANCIAL FREEDOM CALCULATOR - SRI LANKA'), nl,
    write('================================================================'), nl, nl,
    write('This system will analyze your finances and create a personalized'), nl,
    write('roadmap to financial independence.'), nl, nl,
    write('(All amounts in Sri Lankan Rupees - LKR)'), nl,
    write('(Press Enter to use default value in brackets)'), nl, nl,
    write('----------------------------------------------------------------'), nl, nl,
    
    write('Your age? [25]: '), 
    read_input(In1), (In1 = "" -> Age=25 ; atom_number(In1, Age)),
    
    write('Monthly income (after tax)? [100000]: '), 
    read_input(In2), (In2 = "" -> MonthlyIncome=100000 ; atom_number(In2, MonthlyIncome)),
    
    write('Monthly expenses? [60000]: '), 
    read_input(In3), (In3 = "" -> MonthlyExpenses=60000 ; atom_number(In3, MonthlyExpenses)),
    
    write('Total debt (all loans)? [200000]: '), 
    read_input(In4), (In4 = "" -> Debt=200000 ; atom_number(In4, Debt)),
    
    write('Is your debt critical right now? (yes/no) [no]: '),
    read_input(In5), (In5 = "" -> DebtCriticalInput = no ; atom_string(DebtCriticalInput, In5)),
    (DebtCriticalInput = yes -> DebtCritical = yes ; DebtCritical = no),
    
    write('Emergency fund balance? [150000]: '), 
    read_input(In6), (In6 = "" -> EmergencyBalance=150000 ; atom_number(In6, EmergencyBalance)),
    
    write('Regular savings balance? [200000]: '), 
    read_input(In7), (In7 = "" -> Savings=200000 ; atom_number(In7, Savings)),
    
    write('Current investments value? [500000]: '), 
    read_input(In8), (In8 = "" -> Investments=500000 ; atom_number(In8, Investments)),
    
    nl, write('Generating your personalized financial freedom report...'), nl, nl,
    
    generate_financial_report(Age, MonthlyIncome, MonthlyExpenses, Debt, DebtCritical,
                            EmergencyBalance, Savings, Investments, Report),
    
    write(Report), nl, nl,
    write('----------------------------------------------------------------'), nl,
    write('Type "start." for new assessment or "halt." to exit.'), nl,
    write('----------------------------------------------------------------'), nl, nl.

read_input(Atom) :-
    read_line_to_codes(user_input, Codes),
    (Codes = [] -> Atom = "" ; atom_codes(Atom, Codes)).

% ===========================
% HTTP SERVER - FIXED VERSION
% ===========================

server(Port) :-
    ensure_no_existing_server(Port),
    sleep(0.5),
    
    format('~n================================================================~n', []),
    format('  Financial Advisor HTTP Server Starting...~n', []),
    format('================================================================~n', []),
    format('  Port: ~w~n', [Port]),
    format('  Endpoint: http://localhost:~w/financial_advisor~n', [Port]),
    format('================================================================~n~n', []),
    format('Example API call:~n', []),
    format('curl "http://localhost:~w/financial_advisor?age=25&income=100000&expenses=60000&debt=200000&debt_critical=no&emergency=150000&savings=200000&investments=500000"~n~n', [Port]),
    format('Server is running. Press Ctrl+C to stop.~n~n', []),
    
    catch(
        http_server(http_dispatch, [port(Port)]),
        Error,
        (
            format('ERROR: Could not start server: ~w~n', [Error]),
            format('The port may still be in use. Try these steps:~n', []),
            format('1. stop_all_servers.~n', []),
            format('2. kill_server_thread(~w).~n', [Port]),
            format('3. If that fails, restart SWI-Prolog completely.~n', []),
            fail
        )
    ).

stop_server(Port) :-
    catch(
        (http_stop_server(Port, []),
         format('Server on port ~w stopped successfully.~n', [Port])),
        Error,
        (format('Note: ~w~n', [Error]),
         format('No server was running on port ~w.~n', [Port]))
    ).

stop_all_servers :-
    format('~nStopping all HTTP servers...~n', []),
    catch(
        (http_stop_server(8080, []), format('  - Port 8080 stopped~n', [])),
        _, format('  - Port 8080 not running~n', [])
    ),
    catch(
        (http_stop_server(8082, []), format('  - Port 8082 stopped~n', [])),
        _, format('  - Port 8082 not running~n', [])
    ),
    catch(
        (http_stop_server(8000, []), format('  - Port 8000 stopped~n', [])),
        _, format('  - Port 8000 not running~n', [])
    ),
    format('Done.~n~n', []).

restart_server(Port) :-
    format('~nRestarting server on port ~w...~n', [Port]),
    stop_server(Port),
    sleep(1),
    server(Port).

kill_server_thread(Port) :-
    format('~nAttempting to kill server thread on port ~w...~n', [Port]),
    format(atom(DefaultAlias), 'http@~w', [Port]),
    format(atom(PortStr), '~w', [Port]),
    
    findall(Id-Alias,
        ( catch(thread_property(Id, alias(Alias)), _, fail),
          ( Alias = DefaultAlias
          ; sub_atom(Alias, _, _, _, PortStr)
          )
        ), Pairs),
    
    ( Pairs = [] ->
        format('No server thread found for port ~w.~n', [Port])
    ; forall(member(Id-Alias, Pairs), (
            catch((thread_signal(Id, abort), format('Thread ~w (alias ~w) killed.~n', [Id, Alias])), E,
                  format('Could not kill thread ~w (alias ~w): ~w~n', [Id, Alias, E]))
        ))
    ),
    catch(http_stop_server(Port, []), _, true),
    format('Cleanup complete for port ~w.~n', [Port]).

ensure_no_existing_server(Port) :-
    format(atom(DefaultAlias), 'http@~w', [Port]),
    format(atom(PortStr), '~w', [Port]),
    
    findall(TId-Alias,
        (   catch(thread_property(TId, alias(Alias)), _, fail),
            (   Alias = DefaultAlias
            ;   sub_atom(Alias, _, _, _, PortStr)
            )
        ),
        Pairs),
    
    ( Pairs = [] ->
        format('No existing server threads found for port ~w.~n', [Port])
    ;   format('Cleaning up ~w existing thread(s) for port ~w...~n', [length(Pairs), Port]),
        forall(member(T-A, Pairs), (
            catch((thread_signal(T, abort), format('  Aborted thread ~w (alias ~w)~n', [T, A])), E,
                  format('  Warning: could not abort thread ~w: ~w~n', [T, E]))
        ))
    ),
    
    catch(http_stop_server(Port, []), _, true),
    sleep(0.3).

% ===========================
% TESTING PREDICATES
% ===========================

test_json_response :-
    format('~n=== Testing JSON Response Generation ===~n~n', []),
    generate_financial_report_json(
        25, 100000, 60000, 200000, no,
        150000, 200000, 500000, Dict
    ),
    format('Generated JSON Response:~n~n', []),
    json_write(user_output, Dict, [width(80)]), nl, nl.

test_api_call :-
    format('~n=== Simulating API Call ===~n~n', []),
    Age = 25,
    MonthlyIncome = 100000,
    MonthlyExpenses = 60000,
    Debt = 200000,
    DebtCritical = no,
    EmergencyBalance = 150000,
    Savings = 200000,
    Investments = 500000,
    
    generate_financial_report_json(
        Age, MonthlyIncome, MonthlyExpenses, Debt, DebtCritical,
        EmergencyBalance, Savings, Investments, ReportDict
    ),
    
    format('HTTP/1.1 200 OK~n', []),
    format('Content-Type: application/json~n~n', []),
    json_write(user_output, ReportDict, [width(80)]), nl, nl.

test_compact_json :-
    format('~n=== Compact JSON Output ===~n~n', []),
    generate_financial_report_json(
        25, 100000, 60000, 200000, no,
        150000, 200000, 500000, Dict
    ),
    with_output_to(atom(JsonAtom), json_write(current_output, Dict)),
    write(JsonAtom), nl, nl.

% ===========================
% HELPER - Display menu
% ===========================

menu :-
    format('~n================================================================~n', []),
    format('  FINANCIAL ADVISOR SYSTEM v5.5 - MAIN MENU~n', []),
    format('================================================================~n', []),
    format('~n  Available Commands:~n~n', []),
    format('  1. start.                  - Interactive financial assessment~n', []),
    format('  2. server(8080).           - Start HTTP API server on port 8080~n', []),
    format('  3. stop_server(8080).      - Stop server on specific port~n', []),
    format('  4. stop_all_servers.       - Stop all running servers~n', []),
    format('  5. restart_server(8080).   - Restart server on port~n', []),
    format('  6. kill_server_thread(8080). - Force kill server thread~n', []),
    format('  7. test_json_response.     - Test JSON generation~n', []),
    format('  8. test_api_call.          - Test API call simulation~n', []),
    format('  9. test_compact_json.      - Test compact JSON output~n', []),
    format('  10. menu.                  - Show this menu~n', []),
    format('  11. halt.                  - Exit the system~n', []),
    format('~n================================================================~n', []),
    format('~n  FIXED ISSUES IN v5.5:~n', []),
    format('  - Removed custom alias generation that caused race conditions~n', []),
    format('  - Simplified server startup using standard http@Port alias~n', []),
    format('  - Improved cleanup to find ALL threads related to a port~n', []),
    format('  - Better error messages and recovery steps~n', []),
    format('~n================================================================~n~n', []).

:- initialization(menu).

% ------------------------------------------------------------------
% Calculate FI timelines for markdown format
% ------------------------------------------------------------------
calculate_all_timelines_markdown(Age, MonthlyExpenses, CurrentAssets, MonthlyInv, ROIList, TimelinesText) :-
    findall(Line,
        (member(ROI, ROIList),
         calculate_fi_timeline(Age, MonthlyExpenses, CurrentAssets, MonthlyInv, ROI, Years, AgeAtFI),
         format_timeline_markdown(ROI, Years, AgeAtFI, Line)
        ),
    Lines),
    atomic_list_concat(['| ROI | Years to FI | Age at FI |', '|-----|-------------|-----------|' | Lines], '\n', TimelinesText).

format_timeline_markdown(ROI, Years, AgeAtFI, Line) :-
    (Years = impossible ->
        format(atom(Line), '| ~w% | IMPOSSIBLE | - |', [ROI])
    ; Years = over_50 ->
        format(atom(Line), '| ~w% | >50 years | - |', [ROI])
    ; Years = 0 ->
        format(atom(Line), '| ~w% | **ACHIEVED!** | Current |', [ROI])
    ;
        format(atom(Line), '| ~w% | ~w years | ~w |', [ROI, Years, AgeAtFI])
    ).

% ===========================
% CORE FINANCIAL CALCULATIONS
% ===========================

calculate_financial_health_score(MonthlyIncome, MonthlyExpenses, Debt, EmergencyBalance, Savings, Investments, Score, Reasons) :-
    MonthlySavings is MonthlyIncome - MonthlyExpenses,
    (MonthlyIncome > 0 -> 
        SavingsRate is (MonthlySavings / MonthlyIncome) * 100
    ; SavingsRate = 0),
    (SavingsRate =< 0 -> SavingsRateScore = 0
    ; SavingsRate < 10 -> SavingsRateScore = 5
    ; SavingsRate < 20 -> SavingsRateScore = 15
    ; SavingsRate < 30 -> SavingsRateScore = 20
    ; SavingsRateScore = 25),
    
    (MonthlyExpenses > 0 ->
        EmergencyMonths is EmergencyBalance / MonthlyExpenses
    ; EmergencyMonths = 0),
    (EmergencyMonths < 1 -> EmergencyScore = 0
    ; EmergencyMonths < 3 -> EmergencyScore = 10
    ; EmergencyMonths < 6 -> EmergencyScore = 20
    ; EmergencyScore = 25),
    
    AnnualIncome is MonthlyIncome * 12,
    (AnnualIncome > 0 ->
        DebtRatio is Debt / AnnualIncome
    ; DebtRatio = 999),
    (DebtRatio > 2 -> DebtScore = 0
    ; DebtRatio > 1 -> DebtScore = 5
    ; DebtRatio > 0.5 -> DebtScore = 10
    ; DebtRatio > 0.3 -> DebtScore = 15
    ; DebtRatio > 0.1 -> DebtScore = 20
    ; DebtScore = 25),
    
    TotalAssets is Savings + Investments + EmergencyBalance,
    (TotalAssets < 100000 -> InvestmentScore = 0
    ; TotalAssets < 500000 -> InvestmentScore = 5
    ; TotalAssets < 1000000 -> InvestmentScore = 10
    ; TotalAssets < 3000000 -> InvestmentScore = 15
    ; TotalAssets < 5000000 -> InvestmentScore = 20
    ; InvestmentScore = 25),
    
    Score is SavingsRateScore + EmergencyScore + DebtScore + InvestmentScore,
    
    (SavingsRate < 10 -> SR_Text = 'Need significant improvement' 
    ; SavingsRate < 20 -> SR_Text = 'Average, can improve'
    ; SavingsRate < 30 -> SR_Text = 'Good savings habit'
    ; SR_Text = 'Excellent savings discipline'),
    
    (EmergencyMonths < 3 -> EM_Text = 'CRITICAL: Build to 3 months minimum'
    ; EmergencyMonths < 6 -> EM_Text = 'Adequate, aim for 6 months'
    ; EM_Text = 'Strong emergency protection'),
    
    (DebtRatio > 1 -> DR_Text = 'HIGH RISK: Debt exceeds annual income'
    ; DebtRatio > 0.5 -> DR_Text = 'Moderate burden, needs attention'
    ; DebtRatio > 0.3 -> DR_Text = 'Manageable debt level'
    ; DR_Text = 'Low debt, excellent position'),
    
    (TotalAssets < 500000 -> TA_Text = 'Building foundation'
    ; TotalAssets < 3000000 -> TA_Text = 'Growing wealth steadily'
    ; TA_Text = 'Strong asset base established'),
    
    format(atom(R1), 'Savings Rate: ~1f%% (~w/25 points) - ~w', [SavingsRate, SavingsRateScore, SR_Text]),
    format(atom(R2), 'Emergency Fund: ~1f months coverage (~w/25 points) - ~w', [EmergencyMonths, EmergencyScore, EM_Text]),
    DebtInt is truncate(Debt),
    TotalAssetsInt is truncate(TotalAssets),
    format(atom(R3), 'Debt Level: Rs. ~:d (~1f%% of annual income, ~w/25 points) - ~w', [DebtInt, DebtRatio * 100, DebtScore, DR_Text]),
    format(atom(R4), 'Total Assets: Rs. ~:d (~w/25 points) - ~w', [TotalAssetsInt, InvestmentScore, TA_Text]),
    
    format(atom(Reasons), '~w~n~w~n~w~n~w', [R1, R2, R3, R4]).

income_plan(MonthlyIncome, Plan) :-
    (MonthlyIncome < 20000 -> 
        Plan = plan(below_20k, 10, 5, 20, 65, 75, 10,
            'Personal development, Agriculture, Small-scale real estate')
    ; MonthlyIncome >= 20000, MonthlyIncome < 60000 ->
        Plan = plan(low, 50, 10, 20, 20, 30, 10,
            'Money market funds, Unit trusts, Personal development, Treasury bills, Fixed deposits')
    ; MonthlyIncome >= 60000, MonthlyIncome < 120000 ->
        Plan = plan(lower_middle, 30, 20, 30, 20, 40, 10,
            'Renewable energy, Agriculture, Unit trusts, Personal development, Gold, Silver, Treasury bonds, Fixed deposits')
    ; MonthlyIncome >= 120000, MonthlyIncome < 300000 ->
        Plan = plan(upper_middle, 20, 20, 40, 20, 50, 10,
            'Stock market, Equity funds, Agriculture, Renewable energy, Gold, Silver, Personal development, Corporate bonds, Crypto (5% max)')
    ; Plan = plan(high, 10, 10, 60, 20, 70, 10,
            'Stock market, Equity funds, Agriculture, Renewable energy, Real estate, Personal development, International stocks, Corporate bonds, Crypto (5% max), Private equity')
    ).

calculate_allocation(MonthlyIncome, MonthlyExpenses, DebtCritical, Plan, Allocation) :-
    Plan = plan(_, _ConsumptionPct, SavingsPct, InvPctCritical, DebtPctCritical, InvPctNormal, DebtPctNormal, _),
    MonthlySavings is MonthlyIncome - MonthlyExpenses,
    
    (DebtCritical = yes ->
        InvestmentPct = InvPctCritical,
        DebtPct = DebtPctCritical
    ; 
        InvestmentPct = InvPctNormal,
        DebtPct = DebtPctNormal
    ),
    
    InvestmentAmount is (MonthlySavings * InvestmentPct) / 100,
    DebtPayment is (MonthlySavings * DebtPct) / 100,
    EmergencyFund is (MonthlySavings * SavingsPct) / 100,
    Remaining is MonthlySavings - InvestmentAmount - DebtPayment - EmergencyFund,
    
    TrInv is truncate(InvestmentAmount),
    TrDebt is truncate(DebtPayment),
    TrEmerg is truncate(EmergencyFund),
    TrRem is truncate(Remaining),

    Allocation = allocation(TrInv, TrDebt, TrEmerg, TrRem).

calculate_fi_timeline(CurrentAge, MonthlyExpenses, CurrentAssets, MonthlyInvestment, ROI, Years, AgeAtFI) :-
    TargetPassiveIncome is MonthlyExpenses * 12,
    calculate_years_to_target(CurrentAssets, MonthlyInvestment, ROI, TargetPassiveIncome, Years),
    (Years = impossible -> AgeAtFI = impossible
    ; Years = over_50 -> AgeAtFI = over_50
    ; AgeAtFI is CurrentAge + Years).

calculate_years_to_target(CurrentAssets, MonthlyInvestment, ROI, TargetPassiveIncome, Years) :-
    MonthlyROI is ROI / 12 / 100,
    TargetCapital is TargetPassiveIncome / (ROI / 100),

    (CurrentAssets >= TargetCapital ->
        Years = 0
    ;
        PV is CurrentAssets,
        P is MonthlyInvestment,
        FV is TargetCapital,

        (MonthlyROI =:= 0.0 ->
            (P =< 0 -> Years = impossible
            ; MonthsFloat is (FV - PV) / P,
              (MonthsFloat =< 0 -> Years = 0
              ; MonthsFloat > 600 -> Years = over_50
              ; YearsFloatDec is MonthsFloat / 12,
                Years is round(YearsFloatDec * 10) / 10
              )
            )
        ;
            RM = MonthlyROI,
            Numer is FV * RM + P,
            Denom is PV * RM + P,
            (Denom =< 0.0 ->
                Years = impossible
            ; Numer =< 0.0 ->
                Years = impossible
            ;
                Ratio is Numer / Denom,
                (Ratio =< 1.0 ->
                    Years = impossible
                ;
                    MonthsFloat is log(Ratio) / log(1 + RM),
                    (MonthsFloat =< 0 -> Years = 0
                    ; MonthsFloat > 600 -> Years = over_50
                    ; YearsFloatDec is MonthsFloat / 12,
                      Years is round(YearsFloatDec * 10) / 10
                    )
                )
            )
        )
    ).

get_percentages(Plan, DebtCritical, InvPct, DebtPct) :-
    (DebtCritical = yes ->
        Plan = plan(_, _, _, InvPctCritical, DebtPctCritical, _, _, _),
        InvPct = InvPctCritical,
        DebtPct = DebtPctCritical
    ;
        Plan = plan(_, _, _, _, _, InvPctNormal, DebtPctNormal, _),
        InvPct = InvPctNormal,
        DebtPct = DebtPctNormal
    ).

generate_financial_report(Age, MonthlyIncome, MonthlyExpenses, Debt, DebtCritical, 
                          EmergencyBalance, Savings, Investments, Report) :-
    calculate_financial_health_score(MonthlyIncome, MonthlyExpenses, Debt, 
                                    EmergencyBalance, Savings, Investments, 
                                    HealthScore, ScoreReasons),

    income_plan(MonthlyIncome, Plan),
    Plan = plan(IncomeCategory, _, _, _, _, _, _, InvestmentOptions),

    calculate_allocation(MonthlyIncome, MonthlyExpenses, DebtCritical, Plan, Allocation),
    Allocation = allocation(InvAmount, DebtAmount, EmergencyAmount, RemainingAmount),

    get_percentages(Plan, DebtCritical, InvPct, DebtPct),

    CurrentAssets is EmergencyBalance + Savings + Investments,

    ROI_Rates = [8, 12, 16, 20, 24],
    calculate_all_timelines(Age, MonthlyExpenses, CurrentAssets, InvAmount, ROI_Rates, Timelines),

    MonthlySavings is MonthlyIncome - MonthlyExpenses,
    (MonthlyIncome > 0 ->
        SavingsRate is (MonthlySavings / MonthlyIncome) * 100
    ; SavingsRate = 0),

    (HealthScore < 40 -> 
        Assessment = 'NEEDS IMMEDIATE ATTENTION - Focus on basics'
    ; HealthScore < 60 -> 
        Assessment = 'FAIR - Building foundation, keep improving'
    ; HealthScore < 80 -> 
        Assessment = 'GOOD - On the right track'
    ; 
        Assessment = 'EXCELLENT - Strong financial position'
    ),

    (DebtCritical = yes -> 
        DebtStatusText = 'CRITICAL - Priority on debt reduction'
    ; 
        DebtStatusText = 'MANAGEABLE'
    ),

    (DebtCritical = yes ->
        DebtLevelText = 'CRITICAL'
    ;
        DebtLevelText = 'Manageable'
    ),

    MonthlyIncomeInt is truncate(MonthlyIncome),
    MonthlyExpensesInt is truncate(MonthlyExpenses),
    MonthlySavingsInt is truncate(MonthlySavings),
    EmergencyBalanceInt is truncate(EmergencyBalance),
    SavingsInt is truncate(Savings),
    InvestmentsInt is truncate(Investments),
    CurrentAssetsInt is truncate(CurrentAssets),
    DebtInt is truncate(Debt),
    AnnualExpenses is truncate(MonthlyExpenses * 12),

    format(atom(Header), '================================================================~n        COMPREHENSIVE FINANCIAL FREEDOM REPORT~n                  (Sri Lanka - LKR)~n================================================================~n', []),

    format(atom(Section1), '~n================================================================~n STEP 1: YOUR FINANCIAL HEALTH SCORE~n================================================================~n~nOVERALL SCORE: ~w/100~n~n~w~n~nASSESSMENT: ~w~n', 
        [HealthScore, ScoreReasons, Assessment]),

    format(atom(Section2), '~n================================================================~n STEP 2: YOUR INCOME-BASED FINANCIAL PLAN~n================================================================~n~nIncome Category: ~w (Rs. ~:d per month)~nDebt Status: ~w~n~nMONTHLY BREAKDOWN (from Rs. ~:d savings):~n  - For Investments: Rs. ~:d (~w%%)~n  - For Debt Payment: Rs. ~:d (~w%%)~n  - For Emergency Fund: Rs. ~:d~n  - Flexible/Personal Dev: Rs. ~:d~n~nRECOMMENDED INVESTMENT OPTIONS:~n~w~n~nNote: Diversify across multiple options. Never put all money~nin one investment. Start with lower-risk options and gradually~nmove to higher-risk investments as you gain experience.~n',
        [IncomeCategory, MonthlyIncomeInt, DebtStatusText, MonthlySavingsInt,
         InvAmount, InvPct, DebtAmount, DebtPct, EmergencyAmount, RemainingAmount, InvestmentOptions]),

    format(atom(Section3), '~n================================================================~n STEP 3: YOUR CURRENT FINANCIAL STATE~n================================================================~n~nAge: ~w years~nMonthly Income: Rs. ~:d~nMonthly Expenses: Rs. ~:d~nMonthly Savings: Rs. ~:d (~1f%% savings rate)~n~nCurrent Assets:~n  - Emergency Fund: Rs. ~:d~n  - Savings: Rs. ~:d~n  - Investments: Rs. ~:d~n  - TOTAL ASSETS: Rs. ~:d~n~nDebt: Rs. ~:d (~w)~n',
        [Age, MonthlyIncomeInt, MonthlyExpensesInt, MonthlySavingsInt, SavingsRate,
         EmergencyBalanceInt, SavingsInt, InvestmentsInt, CurrentAssetsInt, DebtInt, DebtLevelText]),

    format(atom(Section4), '~n================================================================~n STEP 4: PATH TO FINANCIAL INDEPENDENCE~n================================================================~n~nFinancial Independence Target: Your investments generate~nRs. ~:d per month (Rs. ~:d per year) to cover your expenses.~n~nTIMELINE TO FINANCIAL INDEPENDENCE:~n(Based on monthly investment of Rs. ~:d)~n~n~w~n~nRECOMMENDATION:~n- Conservative approach (8-12%% ROI): Focus on FDs, bonds, funds~n- Balanced approach (12-16%% ROI): Mix of stocks, funds, property~n- Aggressive approach (16-24%% ROI): Stocks, business, real estate~n  (Higher risk, requires knowledge and active management)~n~nChoose a strategy that matches your risk tolerance and financial~nknowledge. Most people achieve 10-15%% average annual returns with~nbalanced diversified portfolios.~n',
        [MonthlyExpensesInt, AnnualExpenses, InvAmount, Timelines]),

    format(atom(Footer), '~n================================================================~n~nImportant Notes:~n1. Review and adjust this plan every 6 months~n2. Emergency fund must reach 6 months expenses before aggressive investing~n3. Pay high-interest debt (>15%%) before investing~n4. Never invest money you cannot afford to lose~n5. Learn before investing - education prevents costly mistakes~n6. Start small, learn, then increase investment amounts~n~n================================================================~n', []),

    atomic_list_concat([Header, Section1, Section2, Section3, Section4, Footer], Report).

 