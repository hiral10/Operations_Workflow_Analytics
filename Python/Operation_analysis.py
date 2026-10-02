import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv(r"C:\Users\Hiral\OneDrive\Documents\Operational-Workflow-Analytics\Data\operations_cleaned.csv")
print(df.head())
print(df.shape)
print(df.columns)
print(f"\n --DataTypes-- \n {df.dtypes}\n")
print(f"\n --Duplicate Values-- \n {df.duplicated().sum()}\n")
print(f"\n --Missing Values-- \n {df.isnull().sum()}\n")

df['Order_Date'] = pd.to_datetime(df['Order_Date'],errors='coerce')
print(f'\n --Order Date datatype--\n{df['Order_Date'].dtype}')
print(f'\n -- Invalid Date--\n{df['Order_Date'].isna().sum()}')

print(f'\n --Numeric Summary-- \n {df[['Processing_Hours','Shipping_Days','Order_Value','SLA_Hours']].describe()} ')

valid_sla = df['Processing_Hours'].notna()
sla_breached = (valid_sla & (df['Processing_Hours']>df['SLA_Hours']))
sla_met = (valid_sla & (df['Processing_Hours']<=df['SLA_Hours']))

print('\n -- SLA Analysis --')
print("Order with valid processing time: " ,valid_sla.sum())
print('SLA met:', sla_met.sum())
print('SLA breached: ',sla_breached.sum())

print('\n SLA Hours missing:', df['SLA_Hours'].isna().sum())
print('\n Processing Hours missing: ',df['Processing_Hours'].isna().sum())

df_clean = df.copy()
print('\n --Regional Value--\n',df_clean['Region'].value_counts(dropna=False))
print('\n --Team Value--\n',df_clean['Team'].value_counts(dropna=False))
print('\n --Department Value--\n',df_clean['Department'].value_counts(dropna=False))
print('\n --Priority Value--\n',df_clean['Priority'].value_counts(dropna=False))

print('\n --Negative Processing hrs--\n',(df_clean['Processing_Hours']<0).sum())
print('\n -- Zero Shipping Days--\n',(df_clean['Shipping_Days']==0).sum())
print('\n --Processing hrs above 70--\n',(df_clean['Processing_Hours']>70).sum())

Q1 = df_clean['Processing_Hours'].quantile(0.25)
Q3 = df_clean['Processing_Hours'].quantile(0.75)
IQR = Q3-Q1

lower_bound = Q1-1.5*IQR
upper_bound = Q3+1.5*IQR

print('\n -- Outlier Analyis--\n')
print('Q1:', round(Q1,2))
print('Q3:', round(Q3,2))
print('IQR:' , round(IQR,2))
print('Lower bound:',round(lower_bound,2))
print('Upper bound',round(upper_bound,2))

outliers = df[(df_clean['Processing_Hours']<lower_bound)| (df_clean['Processing_Hours']>upper_bound)]
print('No of Outliers:',len(outliers))

print('\n--Highest Processing Time--\n',df_clean[['Order_ID','Region','Department','Team','Priority','Processing_Hours','SLA_Hours']].sort_values('Processing_Hours',ascending=False).head(20))

plt.figure(figsize=(10,6))
plt.hist(df_clean['Processing_Hours'].dropna(),bins=30)
plt.xlabel("Processing Hrs")
plt.ylabel('No of Orders')
plt.title('Distribution of order processing time')
#plt.show()

in_10_20 = df_clean[df_clean['Processing_Hours'].between(10,20)]['Processing_Hours'].count()
valid_processing = df_clean['Processing_Hours'].notna().sum()
pct_10_20 = (in_10_20/valid_processing *100)
print('Orders between 10 and 20 hrs',in_10_20)
print('Percentage between 10 and 20 hrs',round(pct_10_20,2),'%')


region_analysis = (df_clean.dropna(subset=['Region','Processing_Hours']).assign(SLA_breached =lambda x:x['Processing_Hours']>x['SLA_Hours']).groupby('Region').agg(total_orders =('Order_ID','count'),breaches = ('SLA_breached','sum')))
region_analysis['breach_rate'] = round((region_analysis['breaches']/region_analysis['total_orders']*100),2)
region_analysis = region_analysis.sort_values('breach_rate',ascending=False)
print("region analysis \n",region_analysis)


plt.figure(figsize=(8,5))
plt.bar(region_analysis.index,region_analysis['breach_rate'])
plt.xlabel("Region")
plt.ylabel("SLA Breach Rate (%)")
plt.title("SLA Breach Rate by Region")
plt.show()
