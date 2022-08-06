clear all; close all

% constants from SAM's SRC/params.f90
Rd    = 287;
Cp    = 1004;

% get SEA STARR forcings
dir_in = './'
%nc_in = sprintf('%s/SEA_STARR_FAST_SCM_driver.nc',dir_in);
%nc_in = sprintf('%s/SEA_STARR_CTRL_SCM_driver.nc',dir_in);
nc_in = sprintf('%s/SEA_STARR_N100_SCM_driver.nc',dir_in);
in = ReadNetcdfVars(nc_in);

lev = in.pa;

in.pres = in.pa_force;
in.z = in.zh;

%% Harmonize time dimensions and delete duplicate times
%  note that base_time is # seconds since  2017-08-15 21:00:00
datenum0 = datenum(2017,8,15,21,00,00);
[yyyy,mm,dd] = datevec(datenum0);
calday = datenum0 - datenum(yyyy-1,12,31) + in.time/86400;
Ntime = length(calday);

% get surface variables
in.Ps = in.ps_force;
in.Tg = in.ts_force;

% choose the initial pressure profile for lev
% no need to flip since index is top-down
lev = in.pa;
Nlev = length(lev);

in.qt = in.qt./(1 - in.qt); % convert to mass mixing ratio
in.Tl = in.ta; 

in.wls = in.wa;
in.omega = in.wap;

mwo3 = 48; mwdry = 28.966;
% convert ozone mole fraction to mass fraction
in.o3mmr = (mwo3/mwdry)*in.o3; % this is a mass fraction
in.o3mmr = in.o3mmr./(1 - in.o3mmr); % convert to mass mixing ratio

% Remove surface omega
out.omega = in.omega;
for k = 1:Ntime
  % based on the notion that the surface omega corresponds to the
  % tide, we choose a vertical structure of the tide-induced
  % omega which is uniformly one up to 700 hPa and zero above 150
  % hPa.  It transitions almost smoothly in between.
  xx = max(0, min(1, (700e2-lev)/(700e2-150e2) ) );
  f = 0.5*(1 + cos(pi*xx ) );
  out.omega(:,k) = out.omega(:,k) - f*out.omega(end,k);
end

% zero out surface pressure tendency because this is equivalent
% to surface omega, which has been removed above.
in.Ptend = zeros(size(in.Ps));

%%%%% OPEN NETCDF FILE FOR FORCINGS %%%%%%%%%%
nc = sprintf('%s_SCAMIOP_Created_%s.nc', ...
             nc_in(1:end-3),datestr(today));
comment = ['Forcings for ORACLES from Michael Diamond. File: ' nc_in ...
           '  converted to netcdf SCAM IOP format by ' ...
           'Ehsan Erfani (Univ of Washington). on ' datestr(today) ...
           '.'];
create_scam_netcdf_file_new(nc,comment,lev,in.lon(1),in.lat(1),yyyy,calday(1:Ntime),9.81*in.orog)
stuff = ncinfo(nc_in);
for n = 1:length(stuff.Attributes)
  ncwriteatt(nc,'/',stuff.Attributes(n).Name,string(stuff.Attributes(n).Value))
end

%%%%% TIMESERIES OF SURFACE/TOA FIELDS (FLUXES, SURFACE TEMP, ETC.) %%%%%%%%%%
%% Note that all variables have dimensions {'time','lat','lon'}
%%   and are single precision.
Variables = { ...
    {'Ps','Pa','Surface Pressure','surface_air_pressure'}, ...
    {'Ptend','Pa/s','Surface Pressure Tendency','tendency_of_surface_air_pressure'}, ...
    {'Tg','K','Surface Temperature (SST if over water)','surface_temperature'}, ...
            };
for n = 1:length(Variables)
  disp(Variables{n}{1})
  nccreate(nc,Variables{n}{1}, ...
           'Dimensions',{'lon','lat','time'}, ...
           'Datatype','single')
  ncwriteatt(nc,Variables{n}{1}, ...
             'units',Variables{n}{2})
  ncwriteatt(nc,Variables{n}{1}, ...
             'long_name',Variables{n}{3})
  ncwriteatt(nc,Variables{n}{1}, ...
             'standard_name',Variables{n}{4})
end

ncwrite(nc,'Ps',reshape(in.Ps(1:Ntime),[1 1 Ntime]));
ncwrite(nc,'Ptend',zeros(1,1,Ntime));
ncwrite(nc,'Tg',reshape(in.Tg(1:Ntime),[1 1 Ntime]));

%%%%% TIMESERIES OF VERTICALLY-VARYING FIELDS (T,q,etc.) %%%%%%%%%%
%% Note that all variables have dimensions {'time','lev','lat','lon'}
%%   and are single precision.
Variables = { ...
    {'z','m','Height','altitude'}, ...
    {'pres','Pa','Pressure','pressure'}, ...
    {'u','m/s','Zonal Wind','eastward_wind'}, ...
    {'v','m/s','Meridional Wind','northward_wind'}, ...
    {'ug','m/s','Geostrophic Zonal Wind','geostrophic_eastward_wind'}, ...
    {'vg','m/s','Geostrophic Meridional Wind','geostrophic_northward_wind'}, ...
    {'omega','Pa/s','Vertical Pressure Velocity','lagrangian_tendency_of_air_pressure'}, ...
    {'T','K','Liquid Water Temperature (Tl = T - (L/Cp)*ql)','air_temperature'}, ...
    {'q','kg/kg','Total Water Mass Mixing Ratio (Vapor + Cloud Liquid)',''}, ...
    {'divT','K/s','Large-scale Horizontal Temperature Advection',''}, ...
    {'divq','K/s','Large-scale Horizontal Advection of Water Vapor Mass Mixing Ratio',''}, ...
    {'Tref','K','Reference Absolute Temperature (Mean over trajectory)','air_temperature'}, ...
    {'qref','kg/kg','Reference Water Vapor Mass Mixing Ratio (Mean over trajectory)',''}, ...
    {'o3mmr','kg/kg','Ozone Mass Mixing Ratio',''}, ...
    {'Na_accum','','Accumulation mode aerosol number mixing ratio','1/kg'}, ...
    {'qa_accum','','Accumulation mode aerosol mass mixing ratio','kg/kg'}, ...
            };
for n = 1:length(Variables)
  disp(Variables{n}{1})
  nccreate(nc,Variables{n}{1}, ...
           'Dimensions',{'lon','lat','lev','time'}, ...
           'Datatype','single')
  ncwriteatt(nc,Variables{n}{1}, ...
             'units',Variables{n}{2})
  ncwriteatt(nc,Variables{n}{1}, ...
             'long_name',Variables{n}{3})
  ncwriteatt(nc,Variables{n}{1}, ...
             'standard_name',Variables{n}{4})
end

ncwrite(nc,'z',reshape(in.z*ones(1,Ntime),[1 1 Nlev Ntime]))
ncwrite(nc,'pres',reshape(in.pa_force,[1 1 Nlev Ntime]))

ncwrite(nc,'u',reshape(in.ua_nud,[1 1 Nlev Ntime]))
ncwrite(nc,'v',reshape(in.va_nud,[1 1 Nlev Ntime]))
ncwrite(nc,'ug',reshape(in.ug,[1 1 Nlev Ntime]))
ncwrite(nc,'vg',reshape(in.vg,[1 1 Nlev Ntime]))
ncwrite(nc,'omega',reshape(out.omega,[1 1 Nlev Ntime]))

ncwrite(nc,'T',reshape(in.ta_nud,[1 1 Nlev Ntime]))
ncwrite(nc,'q',reshape(in.qt_nud,[1 1 Nlev Ntime]))
ncwrite(nc,'divT',zeros(1,1,Nlev,Ntime))
ncwrite(nc,'divq',zeros(1,1,Nlev,Ntime))

ncwrite(nc,'Tref',reshape(in.ta_nud,[1 1 Nlev Ntime]))
ncwrite(nc,'qref',reshape(in.qt_nud,[1 1 Nlev Ntime]))

ncwrite(nc,'o3mmr',reshape(in.o3mmr(:,1:Ntime),[1 1 Nlev Ntime]))

rho_aerosol = 1769; %% This value suggested by Michael.  1300;
rm0 = 92.5e-9; %% This is radius. diameter = 185.e-9;
sg0 = 0.2;

out.na = 1e6*in.na_nud;
qa_over_na = (4*pi/3) *rm0^3 *rho_aerosol *exp((9/2)*log(sg0)^2);

ncwrite(nc,'Na_accum',reshape(out.na,[1 1 Nlev Ntime]))
ncwrite(nc,'qa_accum',reshape(qa_over_na*out.na,[1 1 Nlev Ntime]))






