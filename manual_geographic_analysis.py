#!/usr/bin/env python3
import csv
from collections import defaultdict, Counter

print("LoRTISA Geospatial Analysis")
print("=" * 80)

# Read the CSV file
data = []
headers = []

try:
    with open('LoRTISA_analysis_dataset_corrected.csv', 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        headers = next(reader)
        
        # Find the column indices
        hospital_idx = headers.index('hospital') if 'hospital' in headers else None
        district_idx = headers.index('residencedistrict') if 'residencedistrict' in headers else None
        village_idx = headers.index('residencevillagesubcounty') if 'residencevillagesubcounty' in headers else None
        region_central_idx = headers.index('region_central') if 'region_central' in headers else None
        died_hospital_idx = headers.index('died_hospital') if 'died_hospital' in headers else None
        died_30day_idx = headers.index('died_30day') if 'died_30day' in headers else None
        hiv_positive_idx = headers.index('hiv_positive') if 'hiv_positive' in headers else None
        
        print(f"Column indices found:")
        print(f"  hospital: {hospital_idx}")
        print(f"  residencedistrict: {district_idx}")
        print(f"  residencevillagesubcounty: {village_idx}")
        print(f"  region_central: {region_central_idx}")
        print(f"  died_hospital: {died_hospital_idx}")
        print(f"  died_30day: {died_30day_idx}")
        print(f"  hiv_positive: {hiv_positive_idx}")
        print()
        
        # Read all data
        for row in reader:
            if len(row) > max(filter(None, [hospital_idx, district_idx, village_idx, region_central_idx, 
                                          died_hospital_idx, died_30day_idx, hiv_positive_idx])):
                data.append(row)
                
    print(f"Loaded {len(data)} patient records")
    print("\n" + "=" * 80)

    # 1. Geographic Variables Available
    print("1. GEOGRAPHIC VARIABLES AVAILABLE:")
    print("-" * 50)
    
    # Hospital
    if hospital_idx is not None:
        hospitals = [row[hospital_idx] for row in data if row[hospital_idx].strip()]
        print(f"+ hospital: {len(hospitals)} records")
        hospital_counts = Counter(hospitals)
        for hospital, count in hospital_counts.most_common():
            percentage = (count / len(data)) * 100
            print(f"  - {hospital}: {count} patients ({percentage:.1f}%)")
    
    print()
    
    # Districts
    if district_idx is not None:
        districts = [row[district_idx] for row in data if row[district_idx].strip()]
        print(f"+ residencedistrict: {len(districts)} records")
        district_counts = Counter(districts)
        print(f"  Total unique districts: {len(district_counts)}")
        print("  Top 10 districts:")
        for district, count in district_counts.most_common(10):
            percentage = (count / len(data)) * 100
            print(f"    - {district}: {count} patients ({percentage:.1f}%)")
    
    print()
    
    # Villages/Subcounties
    if village_idx is not None:
        villages = [row[village_idx] for row in data if row[village_idx].strip()]
        print(f"+ residencevillagesubcounty: {len(villages)} records")
        village_counts = Counter(villages)
        print(f"  Total unique villages/subcounties: {len(village_counts)}")
        print("  Top 10 villages/subcounties:")
        for village, count in village_counts.most_common(10):
            percentage = (count / len(data)) * 100
            print(f"    - {village}: {count} patients ({percentage:.1f}%)")
    
    print()
    
    # Region (using region_central as indicator)
    if region_central_idx is not None:
        regions = [row[region_central_idx] for row in data if row[region_central_idx].strip() and row[region_central_idx] != 'NA']
        print(f"+ region (central vs other): {len(regions)} records")
        region_counts = Counter(regions)
        for region_val, count in region_counts.items():
            region_name = "Central" if region_val == "1" else "Other regions"
            percentage = (count / len(data)) * 100
            print(f"  - {region_name}: {count} patients ({percentage:.1f}%)")
    
    print("\n" + "=" * 80)

    # 2. Geographic Distribution of Key Outcomes
    print("2. GEOGRAPHIC DISTRIBUTION OF KEY OUTCOMES:")
    print("-" * 50)
    
    # Hospital mortality by hospital
    if hospital_idx is not None and died_hospital_idx is not None:
        print("\nHOSPITAL MORTALITY BY HOSPITAL:")
        hospital_mortality = defaultdict(lambda: {'total': 0, 'deaths': 0})
        
        for row in data:
            if row[hospital_idx].strip() and row[died_hospital_idx].strip():
                hospital = row[hospital_idx]
                died = 1 if row[died_hospital_idx] == '1' else 0
                hospital_mortality[hospital]['total'] += 1
                hospital_mortality[hospital]['deaths'] += died
        
        for hospital in sorted(hospital_mortality.keys()):
            total = hospital_mortality[hospital]['total']
            deaths = hospital_mortality[hospital]['deaths']
            rate = (deaths / total * 100) if total > 0 else 0
            print(f"  {hospital}: {deaths}/{total} ({rate:.1f}%)")
    
    # 30-day mortality by hospital
    if hospital_idx is not None and died_30day_idx is not None:
        print("\n30-DAY MORTALITY BY HOSPITAL:")
        hospital_30day = defaultdict(lambda: {'total': 0, 'deaths': 0})
        
        for row in data:
            if row[hospital_idx].strip() and row[died_30day_idx].strip():
                hospital = row[hospital_idx]
                died = 1 if row[died_30day_idx] == '1' else 0
                hospital_30day[hospital]['total'] += 1
                hospital_30day[hospital]['deaths'] += died
        
        for hospital in sorted(hospital_30day.keys()):
            total = hospital_30day[hospital]['total']
            deaths = hospital_30day[hospital]['deaths']
            rate = (deaths / total * 100) if total > 0 else 0
            print(f"  {hospital}: {deaths}/{total} ({rate:.1f}%)")
    
    # HIV positive by hospital
    if hospital_idx is not None and hiv_positive_idx is not None:
        print("\nHIV POSITIVE STATUS BY HOSPITAL:")
        hospital_hiv = defaultdict(lambda: {'total': 0, 'positive': 0})
        
        for row in data:
            if row[hospital_idx].strip() and row[hiv_positive_idx].strip():
                hospital = row[hospital_idx]
                hiv_pos = 1 if row[hiv_positive_idx] == '1' else 0
                hospital_hiv[hospital]['total'] += 1
                hospital_hiv[hospital]['positive'] += hiv_pos
        
        for hospital in sorted(hospital_hiv.keys()):
            total = hospital_hiv[hospital]['total']
            positive = hospital_hiv[hospital]['positive']
            rate = (positive / total * 100) if total > 0 else 0
            print(f"  {hospital}: {positive}/{total} ({rate:.1f}%)")
    
    # District-level analysis for top districts
    if district_idx is not None and died_hospital_idx is not None:
        print("\nHOSPITAL MORTALITY BY TOP 10 DISTRICTS:")
        district_mortality = defaultdict(lambda: {'total': 0, 'deaths': 0})
        
        for row in data:
            if row[district_idx].strip() and row[died_hospital_idx].strip():
                district = row[district_idx]
                died = 1 if row[died_hospital_idx] == '1' else 0
                district_mortality[district]['total'] += 1
                district_mortality[district]['deaths'] += died
        
        # Sort by total patients and show top 10
        top_districts = sorted(district_mortality.items(), key=lambda x: x[1]['total'], reverse=True)[:10]
        for district, stats in top_districts:
            total = stats['total']
            deaths = stats['deaths']
            rate = (deaths / total * 100) if total > 0 else 0
            print(f"  {district}: {deaths}/{total} ({rate:.1f}%)")
    
    print("\n" + "=" * 80)

    # 3. Sample Size Assessment for Geospatial Analysis
    print("3. SAMPLE SIZE ASSESSMENT FOR GEOSPATIAL ANALYSIS:")
    print("-" * 50)
    
    min_sample = 30
    good_sample = 100
    
    # Hospital level
    if hospital_idx is not None:
        hospital_counts = Counter([row[hospital_idx] for row in data if row[hospital_idx].strip()])
        print(f"\nHOSPITAL LEVEL:")
        print(f"  Total hospitals: {len(hospital_counts)}")
        adequate_hospitals = sum(1 for count in hospital_counts.values() if count >= min_sample)
        good_hospitals = sum(1 for count in hospital_counts.values() if count >= good_sample)
        print(f"  Hospitals with >={min_sample} patients: {adequate_hospitals}")
        print(f"  Hospitals with >={good_sample} patients: {good_hospitals}")
    
    # District level
    if district_idx is not None:
        district_counts = Counter([row[district_idx] for row in data if row[district_idx].strip()])
        print(f"\nDISTRICT LEVEL:")
        print(f"  Total districts: {len(district_counts)}")
        adequate_districts = sum(1 for count in district_counts.values() if count >= min_sample)
        good_districts = sum(1 for count in district_counts.values() if count >= good_sample)
        small_districts = sum(1 for count in district_counts.values() if count < min_sample)
        print(f"  Districts with >={min_sample} patients: {adequate_districts}")
        print(f"  Districts with >={good_sample} patients: {good_districts}")
        print(f"  Districts with <{min_sample} patients: {small_districts}")
        
        if district_counts:
            print(f"  Largest district sample: {max(district_counts.values())}")
            print(f"  Smallest district sample: {min(district_counts.values())}")
    
    # Village/subcounty level
    if village_idx is not None:
        village_counts = Counter([row[village_idx] for row in data if row[village_idx].strip()])
        print(f"\nVILLAGE/SUBCOUNTY LEVEL:")
        print(f"  Total villages/subcounties: {len(village_counts)}")
        adequate_villages = sum(1 for count in village_counts.values() if count >= min_sample)
        good_villages = sum(1 for count in village_counts.values() if count >= good_sample)
        small_villages = sum(1 for count in village_counts.values() if count < min_sample)
        print(f"  Areas with >={min_sample} patients: {adequate_villages}")
        print(f"  Areas with >={good_sample} patients: {good_villages}")
        print(f"  Areas with <{min_sample} patients: {small_villages}")
        
        if village_counts:
            print(f"  Largest area sample: {max(village_counts.values())}")
            print(f"  Smallest area sample: {min(village_counts.values())}")

    print("\n" + "=" * 80)

    # 4. Geospatial Analysis Recommendations
    print("4. GEOSPATIAL ANALYSIS POTENTIAL & RECOMMENDATIONS:")
    print("-" * 50)
    
    recommendations = []
    
    # Check for coordinate data
    coord_cols = [h for h in headers if any(term in h.lower() for term in ['lat', 'lon', 'coord', 'gps', 'x', 'y'])]
    if coord_cols:
        recommendations.append("+ Potential coordinate data found in columns: " + ", ".join(coord_cols))
    else:
        recommendations.append("! No coordinate data found - will need geocoding of place names")
    
    # Hospital analysis
    if hospital_idx is not None:
        hospital_counts = Counter([row[hospital_idx] for row in data if row[hospital_idx].strip()])
        if len(hospital_counts) >= 2:
            recommendations.append(f"+ Hospital catchment area analysis feasible ({len(hospital_counts)} hospitals)")
    
    # District analysis
    if district_idx is not None:
        district_counts = Counter([row[district_idx] for row in data if row[district_idx].strip()])
        adequate_districts = sum(1 for count in district_counts.values() if count >= min_sample)
        total_districts = len(district_counts)
        if adequate_districts >= 5:
            recommendations.append(f"+ District-level analysis possible ({adequate_districts}/{total_districts} districts with adequate samples)")
        else:
            recommendations.append(f"! Limited district analysis ({adequate_districts}/{total_districts} districts with adequate samples)")
    
    # Village analysis
    if village_idx is not None:
        village_counts = Counter([row[village_idx] for row in data if row[village_idx].strip()])
        adequate_villages = sum(1 for count in village_counts.values() if count >= min_sample)
        total_villages = len(village_counts)
        if adequate_villages >= 10:
            recommendations.append(f"+ Fine-scale village/subcounty analysis possible ({adequate_villages}/{total_villages} areas with adequate samples)")
        else:
            recommendations.append(f"! Limited fine-scale analysis ({adequate_villages}/{total_villages} areas with adequate samples)")
    
    # Region analysis
    if region_central_idx is not None:
        region_counts = Counter([row[region_central_idx] for row in data if row[region_central_idx].strip() and row[region_central_idx] != 'NA'])
        if len(region_counts) >= 2:
            recommendations.append("+ Regional comparison analysis possible (Central vs Other regions)")
    
    print("\nRECOMMENDATIONS:")
    for i, rec in enumerate(recommendations, 1):
        print(f"{i}. {rec}")
    
    # Overall assessment
    positive_recs = len([r for r in recommendations if r.startswith("+")])
    warning_recs = len([r for r in recommendations if r.startswith("!")])
    
    print(f"\nOVERALL GEOSPATIAL ANALYSIS POTENTIAL:")
    if positive_recs >= 3:
        print("EXCELLENT - Multiple geographic levels suitable for comprehensive spatial analysis")
    elif positive_recs >= 2:
        print("GOOD - Several geographic levels suitable for meaningful spatial analysis")
    elif positive_recs >= 1:
        print("MODERATE - Some geographic levels suitable, may need data aggregation")
    else:
        print("LIMITED - May need significant data aggregation or focus on descriptive analysis")
    
    print(f"\nPositive indicators: {positive_recs}")
    print(f"Warning indicators: {warning_recs}")

    print("\n" + "=" * 80)
    print("Analysis complete!")

except FileNotFoundError:
    print("Error: LoRTISA_analysis_dataset_corrected.csv not found")
except Exception as e:
    print(f"Error: {e}")