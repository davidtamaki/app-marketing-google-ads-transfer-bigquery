include: "/app_marketing_analytics_config/adwords_config.view"

include: "ad.view"
include: "age_range.view"
include: "audience.view"
include: "gender.view"
include: "geotargeting.view"
include: "keyword.view"
include: "parental_status.view"
include: "video.view"

view: hour_base {
  extension: required

  dimension: hour_of_day {
    hidden: yes
    type: number
    sql: ${TABLE}.HourOfDay ;;
  }
}

view: transformations_base {
  extension: required

  dimension: ad_network_type {
    hidden: yes
    type: string
    case: {
      when: {
        sql: ${ad_network_type1} = 'SHASTA_AD_NETWORK_TYPE_1_SEARCH' AND ${ad_network_type2} = 'SHASTA_AD_NETWORK_TYPE_2_SEARCH' ;;
        label: "Search"
      }
      when: {
        sql: ${ad_network_type1} = 'SHASTA_AD_NETWORK_TYPE_1_SEARCH' AND ${ad_network_type2} = 'SHASTA_AD_NETWORK_TYPE_2_SEARCH_PARTNERS' ;;
        label: "Search Partners"
      }
      when: {
        sql: ${ad_network_type1} = 'SHASTA_AD_NETWORK_TYPE_1_CONTENT' ;;
        label: "Content"
      }
      else: "Other"
    }
  }

  dimension: device_type {
    hidden: yes
    type: string
    case: {
      when: {
        sql: ${device} LIKE '%Desktop%' ;;
        label: "Desktop"
      }
      when: {
        sql: ${device} LIKE '%Mobile%' ;;
        label: "Mobile"
      }
      when: {
        sql: ${device} LIKE '%Tablet%' ;;
        label: "Tablet"
      }
      else: "Other"
    }
  }
}

explore: ad_impressions_adapter {
  label: "Ad Impressions"
  view_label: "Ad Impressions"
  from: ad_impressions_adapter
  view_name: fact
  hidden: yes

  join: customer {
    from: customer_adapter
    view_label: "Customer"
    sql_on: ${fact.external_customer_id} = ${customer.external_customer_id} AND
      ${fact._date} = ${customer._date} ;;
    relationship: many_to_one
  }
}

view: ad_impressions_adapter {
  extends: [adwords_config, google_adwords_base, transformations_base]
  sql_table_name: {{ fact.adwords_schema._sql }}.AccountBasicStats_{{ fact.adwords_customer_id._sql }} ;;

  dimension: average_position {
    hidden: yes
    type: number
    sql: ${TABLE}.AveragePosition ;;
  }

  dimension: active_view_impressions {
    hidden: yes
    type: number
    sql: ${TABLE}.ActiveViewImpressions ;;
  }

  dimension: active_view_measurability {
    hidden: yes
    type: number
    sql: ${TABLE}.ActiveViewMeasurability ;;
  }

  dimension: active_view_measurable_cost {
    hidden: yes
    type: number
    sql: ${TABLE}.ActiveViewMeasurableCost ;;
  }

  dimension: active_view_measurable_impressions {
    hidden: yes
    type: number
    sql: ${TABLE}.ActiveViewMeasurableImpressions ;;
  }

  dimension: active_view_viewability {
    hidden: yes
    type: number
    sql: ${TABLE}.ActiveViewViewability ;;
  }

  dimension: ad_network_type1 {
    hidden: yes
    type: string
    sql: ${TABLE}.AdNetworkType1 ;;
  }

  dimension: ad_network_type2 {
    hidden: yes
    type: string
    sql: ${TABLE}.AdNetworkType2 ;;
  }

  dimension: clicks {
    hidden: yes
    type: number
    sql: ${TABLE}.clicks ;;
  }

  dimension: conversions {
    hidden: yes
    type: number
    sql: ${TABLE}.conversions ;;
  }

  dimension: conversionvalue {
    hidden: yes
    type: number
    sql: ${TABLE}.conversionvalue ;;
  }

  dimension: cost {
    hidden: yes
    type: number
    sql: ${TABLE}.cost / 1000000;;
  }

  dimension: device {
    hidden: yes
    type: string
    sql: ${TABLE}.Device ;;
  }

  dimension: impressions {
    hidden: yes
    type: number
    sql: ${TABLE}.impressions ;;
  }

  dimension: interactions {
    hidden: yes
    type: number
    sql: ${TABLE}.Interactions ;;
  }

  dimension: interaction_types {
    hidden: yes
    type: string
    sql: ${TABLE}.InteractionTypes ;;
  }

  dimension: slot {
    hidden: yes
    type: string
    sql: ${TABLE}.Slot ;;
  }

  dimension: view_through_conversions {
    hidden: yes
    type: number
    sql: ${TABLE}.ViewThroughConversions ;;
  }
}

explore: ad_impressions_hour_adapter {
  extends: [ad_impressions_adapter]
  from: ad_impressions_hour_adapter
  view_name: fact
}

view: ad_impressions_hour_adapter {
  extends: [ad_impressions_adapter, hour_base]
  sql_table_name: {{ fact.adwords_schema._sql }}.HourlyAccountStats_{{ fact.adwords_customer_id._sql }} ;;
}

explore: ad_impressions_campaign_adapter {
  extends: [ad_impressions_adapter]
  from: ad_impressions_campaign_adapter
  view_name: fact

  join: campaign {
    from: campaign_adapter
    view_label: "Campaign"
    sql_on: ${fact.campaign_id} = ${campaign.campaign_id} AND
      ${fact.external_customer_id} = ${campaign.external_customer_id} AND
      ${fact._date} = ${campaign._date};;
    relationship: many_to_one
  }
}

view: ad_impressions_campaign_adapter {
  extends: [ad_impressions_adapter]
  sql_table_name: {{ fact.adwords_schema._sql }}.CampaignBasicStats_{{ fact.adwords_customer_id._sql }} ;;


  dimension: base_campaign_id {
    hidden: yes
    sql: ${TABLE}.BaseCampaignId ;;
  }

  dimension: campaign_id {
    hidden: yes
    sql: ${TABLE}.CampaignId ;;
  }

  dimension: campaign_id_string {
    hidden: yes
    sql: CAST(${campaign_id} as STRING) ;;
  }
}

explore: ad_impressions_campaign_hour_adapter {
  extends: [ad_impressions_campaign_adapter]
  from: ad_impressions_campaign_hour_adapter
  view_name: fact
}

view: ad_impressions_campaign_hour_adapter {
  extends: [ad_impressions_campaign_adapter, hour_base]
  sql_table_name: {{ fact.adwords_schema._sql }}.HourlyCampaignStats_{{ fact.adwords_customer_id._sql }} ;;
}

explore: ad_impressions_ad_group_adapter {
  extends: [ad_impressions_campaign_adapter]
  from: ad_impressions_ad_group_adapter
  view_name: fact

  join: ad_group {
    from: ad_group_adapter
    view_label: "Ad Groups"
    sql_on: ${fact.ad_group_id} = ${ad_group.ad_group_id} AND
      ${fact.campaign_id} = ${ad_group.campaign_id} AND
      ${fact.external_customer_id} = ${ad_group.external_customer_id} AND
      ${fact._date} = ${ad_group._date} ;;
    relationship: many_to_one
  }
}

view: ad_impressions_ad_group_adapter {
  extends: [ad_impressions_campaign_adapter]
  sql_table_name: {{ fact.adwords_schema._sql }}.AdGroupBasicStats_{{ fact.adwords_customer_id._sql }} ;;

  dimension: ad_group_id {
    hidden: yes
    sql: ${TABLE}.AdGroupId ;;
  }

  dimension: ad_group_id_string {
    hidden: yes
    sql: CAST(${ad_group_id} as STRING) ;;
  }

  dimension: base_ad_group_id {
    hidden: yes
    sql: ${TABLE}.BaseAdGroupId ;;
  }
}

explore: ad_impressions_ad_group_hour_adapter {
  extends: [ad_impressions_ad_group_adapter]
  from: ad_impressions_ad_group_hour_adapter
  view_name: fact
}

view: ad_impressions_ad_group_hour_adapter {
  extends: [ad_impressions_ad_group_adapter, hour_base]
  sql_table_name: {{ fact.adwords_schema._sql }}.HourlyAdGroupStats_{{ fact.adwords_customer_id._sql }} ;;
}

explore: ad_impressions_keyword_adapter {
  extends: [ad_impressions_ad_group_adapter]
  from: ad_impressions_keyword_adapter
  view_name: fact

  join: keyword {
    from: keyword_adapter
    view_label: "Keyword"
    sql_on: ${fact.criterion_id} = ${keyword.criterion_id} AND
      ${fact.ad_group_id} = ${keyword.ad_group_id} AND
      ${fact.campaign_id} = ${keyword.campaign_id} AND
      ${fact.external_customer_id} = ${keyword.external_customer_id} AND
      ${fact._date} = ${keyword._date} ;;
    relationship: many_to_one
  }
}

view: ad_impressions_keyword_adapter {
  extends: [ad_impressions_ad_group_adapter]
  sql_table_name: {{ fact.adwords_schema._sql }}.KeywordBasicStats_{{ fact.adwords_customer_id._sql }} ;;

  dimension: criterion_id {
    hidden: yes
    sql: ${TABLE}.CriterionId ;;
  }

  dimension: criterion_id_string {
    hidden: yes
    sql: CAST(${criterion_id} as STRING) ;;
  }
}

explore: ad_impressions_ad_adapter {
  extends: [ad_impressions_keyword_adapter]
  from: ad_impressions_ad_adapter
  view_name: fact

  join: ad {
    from: ad_adapter
    view_label: "Ads"
    sql_on: ${fact.creative_id} = ${ad.creative_id} AND
      ${fact.ad_group_id} = ${ad.ad_group_id} AND
      ${fact.campaign_id} = ${ad.campaign_id} AND
      ${fact.external_customer_id} = ${ad.external_customer_id} AND
      ${fact._date} = ${ad._date} ;;
    relationship:  many_to_one
  }
}

view: ad_impressions_ad_adapter {
  extends: [ad_impressions_keyword_adapter]
  sql_table_name: {{ fact.adwords_schema._sql }}.AdBasicStats_{{ fact.adwords_customer_id._sql }} ;;

  dimension: creative_id {
    hidden: yes
    sql: ${TABLE}.CreativeId ;;
  }

  dimension: creative_id_string {
    hidden: yes
    sql: CAST(${creative_id} as STRING) ;;
  }
}

explore: ad_impressions_age_range_adapter {
  extends: [ad_impressions_keyword_adapter]
  from: ad_impressions_age_range_adapter
  view_name: fact

  join: age_range {
    from: age_range_adapter
    view_label: "Age Range"
    sql_on: ${fact.criterion_id} = ${age_range.criterion_id} AND
      ${fact.ad_group_id} = ${age_range.ad_group_id} AND
      ${fact.campaign_id} = ${age_range.campaign_id} AND
      ${fact.external_customer_id} = ${age_range.external_customer_id} AND
      ${fact._date} = ${age_range._date} ;;
    relationship: many_to_one
  }
}

view: ad_impressions_age_range_adapter {
  extends: [ad_impressions_keyword_adapter]
  sql_table_name: {{ fact.adwords_schema._sql }}.AgeRangeBasicStats_{{ fact.adwords_customer_id._sql }} ;;
}

explore: ad_impressions_audience_adapter {
  extends: [ad_impressions_keyword_adapter]
  from: ad_impressions_audience_adapter
  view_name: fact

  join: audience {
    from: audience_adapter
    view_label: "Audience"
    sql_on: ${fact.criterion_id} = ${audience.criterion_id} AND
      ${fact.ad_group_id} = ${audience.ad_group_id} AND
      ${fact.campaign_id} = ${audience.campaign_id} AND
      ${fact.external_customer_id} = ${audience.external_customer_id} AND
      ${fact._date} = ${audience._date} ;;
    relationship: many_to_one
  }
}

view: ad_impressions_audience_adapter {
  extends: [ad_impressions_keyword_adapter]
  sql_table_name: {{ fact.adwords_schema._sql }}.AudienceBasicStats_{{ fact.adwords_customer_id._sql }} ;;
}

explore: ad_impressions_gender_adapter {
  extends: [ad_impressions_keyword_adapter]
  from: ad_impressions_gender_adapter
  view_name: fact

  join: gender {
    from: gender_adapter
    view_label: "Gender"
    sql_on: ${fact.criterion_id} = ${gender.criterion_id} AND
      ${fact.ad_group_id} = ${gender.ad_group_id} AND
      ${fact.campaign_id} = ${gender.campaign_id} AND
      ${fact.external_customer_id} = ${gender.external_customer_id} AND
      ${fact._date} = ${gender._date} ;;
    relationship: many_to_one
  }
}

view: ad_impressions_gender_adapter {
  extends: [ad_impressions_keyword_adapter]
  sql_table_name: {{ fact.adwords_schema._sql }}.GenderBasicStats_{{ fact.adwords_customer_id._sql }} ;;
}

explore: ad_impressions_parental_status_adapter {
  extends: [ad_impressions_keyword_adapter]
  from: ad_impressions_parental_status_adapter
  view_name: fact

  join: parental_status {
    from: parental_status_adapter
    view_label: "Parental Status"
    sql_on: ${fact.criterion_id} = ${parental_status.criterion_id} AND
      ${fact.ad_group_id} = ${parental_status.ad_group_id} AND
      ${fact.campaign_id} = ${parental_status.campaign_id} AND
      ${fact.external_customer_id} = ${parental_status.external_customer_id} AND
      ${fact._date} = ${parental_status._date} ;;
    relationship: many_to_one
  }
}

view: ad_impressions_parental_status_adapter {
  extends: [ad_impressions_keyword_adapter]
  sql_table_name: {{ fact.adwords_schema._sql }}.ParentalStatusBasicStats_{{ fact.adwords_customer_id._sql }} ;;
}

explore: ad_impressions_video_adapter {
  extends: [ad_impressions_ad_group_adapter]
  from: ad_impressions_video_adapter
  view_name: fact

  join: video {
    from: video_adapter
    view_label: "Video"
    sql_on: ${fact.video_id} = ${video.video_id} AND
      ${fact.ad_group_id} = ${video.ad_group_id} AND
      ${fact.campaign_id} = ${video.campaign_id} AND
      ${fact.external_customer_id} = ${video.external_customer_id} AND
      ${fact._date} = ${video._date} ;;
    relationship: many_to_one
  }
}

view: ad_impressions_video_adapter {
  extends: [adwords_config, google_adwords_base, transformations_base]
  sql_table_name: {{ fact.adwords_schema._sql }}.VideoBasicStats_{{ fact.adwords_customer_id._sql }} ;;

  dimension: ad_group_id {
    hidden: yes
    sql: ${TABLE}.AdGroupId ;;
  }

  dimension: ad_group_id_string {
    hidden: yes
    sql: CAST(${ad_group_id} as STRING) ;;
  }

  dimension: ad_network_type1 {
    hidden: yes
    type: string
    sql: ${TABLE}.AdNetworkType1 ;;
  }

  dimension: ad_network_type2 {
    hidden: yes
    type: string
    sql: ${TABLE}.AdNetworkType2 ;;
  }

  dimension: campaign_id {
    hidden: yes
    sql: ${TABLE}.CampaignId ;;
  }

  dimension: campaign_id_string {
    hidden: yes
    sql: CAST(${campaign_id} as STRING) ;;
  }

  dimension: clicks {
    hidden: yes
    type: number
    sql: ${TABLE}.clicks ;;
  }

  dimension: conversions {
    hidden: yes
    type: number
    sql: ${TABLE}.conversions ;;
  }

  dimension: conversionvalue {
    hidden: yes
    type: number
    sql: ${TABLE}.conversionvalue ;;
  }

  dimension: cost {
    hidden: yes
    type: number
    sql: ${TABLE}.cost / 1000000;;
  }

  dimension: creative_id {
    hidden: yes
    sql: ${TABLE}.CreativeId ;;
  }

  dimension: creative_id_string {
    hidden: yes
    sql: CAST(${creative_id} as STRING) ;;
  }

  dimension: creative_status {
    hidden: yes
    sql: ${TABLE}.CreativeStatus ;;
  }

  dimension: device {
    hidden: yes
    type: string
    sql: ${TABLE}.Device ;;
  }

  dimension: impressions {
    hidden: yes
    type: number
    sql: ${TABLE}.impressions ;;
  }

  dimension: video_id {
    hidden: yes
    sql: ${TABLE}.VideoId ;;
  }

  dimension: video_channel_id {
    hidden: yes
    sql: ${TABLE}.VideoChannelId ;;
  }

  dimension: view_through_conversions {
    hidden: yes
    type: number
    sql: ${TABLE}.ViewThroughConversions ;;
  }
}

explore: ad_impressions_geo_adapter {
  extends: [ad_impressions_ad_group_adapter]
  from: ad_impressions_geo_adapter
  view_name: fact

  join: geo_country {
    from: geotargeting
    view_label: "Country"
    fields: [country_code]
    sql_on: ${fact.country_criteria_id} = ${geo_country.criteria_id} ;;
    relationship: many_to_one
  }

  join: geo_us_state {
    from: geotargeting
    view_label: "US State"
    fields: [state]
    sql_on: ${fact.region_criteria_id} = ${geo_us_state.criteria_id} AND
      ${geo_us_state.is_us_state} ;;
    relationship: many_to_one
    type: inner
  }

  join: geo_us_postal_code {
    from: geotargeting
    view_label: "US Postal Code"
    fields: [postal_code]
    sql_on: ${fact.most_specific_criteria_id} = ${geo_us_postal_code.criteria_id} AND
      ${geo_us_postal_code.is_us_postal_code} ;;
    relationship: many_to_one
    type: inner
  }

  join: geo_us_postal_code_state {
    from: geotargeting
    view_label: "US Postal Code"
    fields: [state]
    sql_on: ${geo_us_postal_code.parent_id} = ${geo_us_postal_code_state.criteria_id} AND
      ${geo_us_postal_code_state.is_us_state} ;;
    relationship: many_to_one
    type: inner
    required_joins: [geo_us_postal_code]
  }

  join: geo_region {
    from: geotargeting
    view_label: "Region"
    fields: [name, country_code]
    sql_on: ${fact.region_criteria_id} = ${geo_region.criteria_id} ;;
    relationship: many_to_one
  }

  join: geo_metro {
    from: geotargeting
    view_label: "Metro"
    fields: [name, country_code]
    sql_on: ${fact.metro_criteria_id} = ${geo_metro.criteria_id} ;;
    relationship: many_to_one
  }

  join: geo_city {
    from: geotargeting
    view_label: "City"
    fields: [name, country_code]
    sql_on: ${fact.city_criteria_id} = ${geo_city.criteria_id} ;;
    relationship: many_to_one
  }
}

view: ad_impressions_geo_adapter {
  extends: [ad_impressions_ad_group_adapter]
  sql_table_name: {{ fact.adwords_schema._sql }}.GeoStats_{{ fact.adwords_customer_id._sql }} ;;

  dimension: city_criteria_id {
    hidden: yes
    type: number
    sql: ${TABLE}.CityCriteriaId ;;
  }

  dimension: country_criteria_id {
    hidden: yes
    type: number
    sql: ${TABLE}.CountryCriteriaId ;;
  }

  dimension: metro_criteria_id {
    hidden: yes
    type: number
    sql: ${TABLE}.MetroCriteriaId ;;
  }

  dimension: most_specific_criteria_id {
    hidden: yes
    type: number
    sql: ${TABLE}.MostSpecificCriteriaId ;;
  }

  dimension: region_criteria_id {
    hidden: yes
    type: number
    sql: ${TABLE}.RegionCriteriaId ;;
  }
}
