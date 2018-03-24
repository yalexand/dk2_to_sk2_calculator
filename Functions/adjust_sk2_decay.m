function ret = adjust_sk2_decay( tau_D_, tau_DA_, beta_DA_ )

    if ~(beta_DA_>=0 && beta_DA_<=1)
        disp('bad input');
        return;
    end

    ret = [];

    tauD = tau_D_;
    tauDA_2exp = tau_DA_;
    betaDA_2exp = beta_DA_;

    % :)
    sec = 1;
    Hz = 1;
    mega = 1e6;
    nano = 1e-9;
    pico = 1e-12;

    NGates = 4096;

    f = 20*mega*Hz;
    Tp = 1/f/(pico*sec);
    DT = Tp/NGates;
    t = DT*(0:NGates - 1);

    E = 1e-3:1e-3:1-1e-3; % efficiency
    E_avr = 0;
    tau_FRET_avr = 0;
    
    %
    options = optimset('Jacobian','off','Display','on');
    options.MaxFunEvals = 600;                                
    
    Eini = 1-tauDA_2exp/tauD;
    guess_eta = (1/Eini-1)^(1/6);    
    guess_fD = 1 - betaDA_2exp*tauDA_2exp/(betaDA_2exp*tauDA_2exp + (1-betaDA_2exp)*tauD);
    %
    fD_2exp = guess_fD;
    
    LO = [0 0];            
    UP = [1 2];
    x = fminsearchbnd(@decay_diff_2exp_sk2,[guess_fD guess_eta],LO,UP,options); 
    % x = fminsearch(@decay_diff_2exp_sk2,[guess_fD guess_eta],options); 
                            
    fD_rstrd    = x(1);
    eta_rstrd   = x(2);    
                
                tau = tauD*(1-E);
                pE = sk2_efficiency_distribution(eta_rstrd,E);
                tau_FRET_avr = sum(tau.*pE)/sum(pE);                           
                beta_FRET = 1 - fD_rstrd/tauD/(fD_rstrd/tauD + (1-fD_rstrd)/tau_FRET_avr);
    
    ret.tau_D = tauD;
    ret.eta_dk2 = guess_eta;    
    ret.eta_sk2 = eta_rstrd;
        ret.beta_DA_dk2 = betaDA_2exp;        
        ret.beta_DA_sk2 = beta_FRET;    
            ret.tau_DA_dk2 = tauDA_2exp;
            ret.tau_DA_sk2 = tau_FRET_avr;
                ret.E_dk2 = Eini;
                ret.E_sk2 = sum(E.*pE)/sum(pE);
    
    %--------------------------------------------------
    function decay = const_decay_2exp()    
        decay = fD_2exp/tauD/(1-exp(-Tp/tauD)).*exp(-t/tauD) + ... 
            (1-fD_2exp)/tauDA_2exp/(1-exp(-Tp/tauDA_2exp)).*exp(-t/tauDA_2exp);
    end
    %
    %--------------------------------------------------
    function decay = decay_sk2(x)
        fD = x(1);
        eta = x(2);

        Nb = numel(t);
        Np = numel(E);    

        tau = tauD.*(1-E);
        pE = sk2_efficiency_distribution(eta,E);

        FRETSUM = zeros(1,Nb);

        for p = 1:Np
            FRETSUM = FRETSUM + pE(p)/tau(p)*exp(-t/tau(p))/(1-exp(-Tp/tau(p)));
        end
        FRETSUM = FRETSUM/sum(pE);

        decay = ( fD*1/tauD*exp(-t/tauD)/(1-exp(-Tp/tauD)) + (1-fD)*FRETSUM );

        E_avr = sum(pE.*E)/sum(pE);
        tau_FRET_avr = sum(tau.*pE)/sum(pE);    
    end
    %--------------------------------------------------
    function decay_diff = decay_diff_2exp_sk2(x)
        decay_diff = norm((const_decay_2exp - decay_sk2(x)));
    end

end

