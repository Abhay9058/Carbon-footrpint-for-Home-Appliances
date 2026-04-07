from datetime import datetime, timedelta
from typing import Dict, List, Optional
from schemas import (
    UserModel, ApplianceModel, UsageLogModel, 
    ApplianceCreate, UsageLogCreate, AnalyticsModel, EcoTipModel
)


EMISSION_FACTOR = 0.82


class Database:
    def __init__(self):
        self.users: Dict[int, UserModel] = {
            1: UserModel(
                id=1,
                username="eco_warrior",
                role="user",
                member_since="2024-01-15",
                total_carbon_emissions=125.5,
                dark_mode=False,
                eco_tips_notifications=True
            )
        }
        self.appliances: Dict[int, ApplianceModel] = {
            1: ApplianceModel(
                id=1,
                user_id=1,
                name="LED Bulb",
                appliance_type="Lighting",
                wattage=10,
                quantity=5,
                created_at="2024-01-16T10:30:00"
            ),
            2: ApplianceModel(
                id=2,
                user_id=1,
                name="Air Conditioner",
                appliance_type="Cooling",
                wattage=1500,
                quantity=1,
                created_at="2024-01-17T14:20:00"
            ),
            3: ApplianceModel(
                id=3,
                user_id=1,
                name="Refrigerator",
                appliance_type="Kitchen",
                wattage=150,
                quantity=1,
                created_at="2024-01-18T09:15:00"
            )
        }
        self.usage_logs: Dict[int, UsageLogModel] = {}
        self.eco_tips: List[EcoTipModel] = [
            EcoTipModel(id=1, title="Switch to LED", description="Replace incandescent bulbs with LED lights to save up to 75% energy.", category="Lighting"),
            EcoTipModel(id=2, title="Optimal Temperature", description="Set AC to 24°C for optimal energy efficiency.", category="Cooling"),
            EcoTipModel(id=3, title="Unplug Idle Devices", description="Unplug chargers and devices when not in use to eliminate phantom energy consumption.", category="General"),
            EcoTipModel(id=4, title="Use Natural Light", description="Maximize natural daylight to reduce artificial lighting needs.", category="Lighting"),
            EcoTipModel(id=5, title="Energy Star Appliances", description="Choose Energy Star certified appliances for 10-50% less energy consumption.", category="General"),
            EcoTipModel(id=6, title="Regular Maintenance", description="Clean AC filters monthly for better efficiency and lower emissions.", category="Cooling"),
            EcoTipModel(id=7, title="Power Strip Strategy", description="Use power strips to easily switch off multiple devices at once.", category="General"),
            EcoTipModel(id=8, title="Efficient Cooking", description="Use lids while cooking to reduce energy usage by up to 30%.", category="Kitchen"),
        ]
        self._next_appliance_id = 4
        self._next_log_id = 1
        self._initialize_sample_usage()

    def _initialize_sample_usage(self):
        from datetime import datetime, timedelta
        
        dates = []
        for i in range(60):
            date = (datetime.now() - timedelta(days=59-i)).strftime("%Y-%m-%d")
            dates.append(date)
        
        sample_logs = [
            (1, 6.0, dates[0]),
            (2, 8.0, dates[1]),
            (3, 24.0, dates[2]),
            (1, 5.0, dates[3]),
            (2, 10.0, dates[4]),
            (1, 7.0, dates[5]),
            (2, 6.0, dates[6]),
            (3, 24.0, dates[7]),
            (1, 4.0, dates[8]),
            (2, 12.0, dates[9]),
            (1, 6.0, dates[10]),
            (2, 8.0, dates[11]),
            (3, 24.0, dates[12]),
            (1, 5.0, dates[13]),
            (2, 10.0, dates[14]),
            (1, 7.0, dates[15]),
            (3, 12.0, dates[16]),
            (2, 8.0, dates[17]),
            (1, 6.0, dates[18]),
            (2, 9.0, dates[19]),
            (3, 24.0, dates[20]),
            (1, 5.0, dates[21]),
            (2, 11.0, dates[22]),
            (1, 6.0, dates[23]),
            (3, 24.0, dates[24]),
            (2, 7.0, dates[25]),
            (1, 5.0, dates[26]),
            (2, 10.0, dates[27]),
            (1, 6.0, dates[28]),
            (3, 24.0, dates[29]),
        ]
        
        for appliance_id, hours, date in sample_logs:
            emission = self.calculate_carbon_emission(appliance_id, hours)
            self.usage_logs[self._next_log_id] = UsageLogModel(
                id=self._next_log_id,
                user_id=1,
                appliance_id=appliance_id,
                hours=hours,
                date=date,
                carbon_emission=emission,
                created_at=datetime.now().isoformat()
            )
            self._next_log_id += 1

    def calculate_carbon_emission(self, appliance_id: int, hours: float) -> float:
        appliance = self.appliances.get(appliance_id)
        if not appliance:
            return 0.0
        emission = (appliance.wattage * hours * appliance.quantity / 1000) * EMISSION_FACTOR
        return round(emission, 3)

    def get_user(self, user_id: int) -> Optional[UserModel]:
        return self.users.get(user_id)

    def update_user(self, user_id: int, username: Optional[str] = None, 
                    dark_mode: Optional[bool] = None, 
                    eco_tips_notifications: Optional[bool] = None) -> Optional[UserModel]:
        user = self.users.get(user_id)
        if not user:
            return None
        if username is not None:
            user.username = username
        if dark_mode is not None:
            user.dark_mode = dark_mode
        if eco_tips_notifications is not None:
            user.eco_tips_notifications = eco_tips_notifications
        return user

    def get_appliances(self, user_id: int) -> List[ApplianceModel]:
        return [a for a in self.appliances.values() if a.user_id == user_id]

    def create_appliance(self, user_id: int, appliance: ApplianceCreate) -> ApplianceModel:
        new_appliance = ApplianceModel(
            id=self._next_appliance_id,
            user_id=user_id,
            name=appliance.name,
            appliance_type=appliance.appliance_type,
            wattage=appliance.wattage,
            quantity=appliance.quantity,
            created_at=datetime.now().isoformat()
        )
        self.appliances[self._next_appliance_id] = new_appliance
        self._next_appliance_id += 1
        return new_appliance

    def delete_appliance(self, appliance_id: int) -> bool:
        if appliance_id in self.appliances:
            del self.appliances[appliance_id]
            return True
        return False

    def create_usage_log(self, user_id: int, log: UsageLogCreate) -> UsageLogModel:
        emission = self.calculate_carbon_emission(log.appliance_id, log.hours)
        new_log = UsageLogModel(
            id=self._next_log_id,
            user_id=user_id,
            appliance_id=log.appliance_id,
            hours=log.hours,
            date=log.date,
            carbon_emission=emission,
            created_at=datetime.now().isoformat()
        )
        self.usage_logs[self._next_log_id] = new_log
        self._next_log_id += 1
        
        user = self.users.get(user_id)
        if user:
            user.total_carbon_emissions += emission
        
        return new_log

    def get_usage_logs(self, user_id: int, limit: Optional[int] = None) -> List[UsageLogModel]:
        logs = sorted(
            [l for l in self.usage_logs.values() if l.user_id == user_id],
            key=lambda x: x.date,
            reverse=True
        )
        if limit:
            return logs[:limit]
        return logs

    def get_analytics(self, user_id: int) -> AnalyticsModel:
        from datetime import datetime, timedelta
        
        logs = [l for l in self.usage_logs.values() if l.user_id == user_id]
        appliances = {a.id: a for a in self.appliances.values() if a.user_id == user_id}
        user = self.users.get(user_id)
        
        today = datetime.now()
        today_str = today.strftime("%Y-%m-%d")
        
        daily_emissions = []
        weekly_total = 0.0
        
        for i in range(7):
            date = (today - timedelta(days=6-i)).strftime("%Y-%m-%d")
            day_logs = [l for l in logs if l.date == date]
            day_emission = sum(l.carbon_emission for l in day_logs)
            daily_emissions.append({
                "date": date,
                "emission": round(day_emission, 3)
            })
        
        last_7_days = [(today - timedelta(days=i)).strftime("%Y-%m-%d") for i in range(7)]
        weekly_logs = [l for l in logs if l.date in last_7_days]
        weekly_total = sum(l.carbon_emission for l in weekly_logs)
        
        monthly_total = 0.0
        month_start = today.replace(day=1)
        month_logs = [l for l in logs if l.date >= month_start.strftime("%Y-%m-%d")]
        monthly_total = sum(l.carbon_emission for l in month_logs)
        
        yearly_total = 0.0
        year_start = today.replace(month=1, day=1)
        year_logs = [l for l in logs if l.date >= year_start.strftime("%Y-%m-%d")]
        yearly_total = sum(l.carbon_emission for l in year_logs)
        
        total_carbon_emissions = user.total_carbon_emissions if user else 0.0
        
        monthly_emissions = []
        for i in range(4):
            week_start = today - timedelta(days=today.weekday() + 7*(3-i))
            week_end = week_start + timedelta(days=6)
            week_logs = [l for l in logs 
                        if week_start.strftime("%Y-%m-%d") <= l.date <= week_end.strftime("%Y-%m-%d")]
            week_emission = sum(l.carbon_emission for l in week_logs)
            monthly_emissions.append({
                "week": f"Week {4-i}",
                "emission": round(week_emission, 3)
            })
        
        emissions_by_appliance = []
        for app_id, appliance in appliances.items():
            app_logs = [l for l in logs if l.appliance_id == app_id]
            total_emission = sum(l.carbon_emission for l in app_logs)
            if total_emission > 0:
                emissions_by_appliance.append({
                    "name": appliance.name,
                    "type": appliance.appliance_type,
                    "emission": round(total_emission, 3),
                    "quantity": appliance.quantity
                })
        
        emissions_by_appliance.sort(key=lambda x: x["emission"], reverse=True)
        top_appliances = emissions_by_appliance[:5]
        
        highest_emission_appliance = emissions_by_appliance[0] if emissions_by_appliance else None
        
        today_logs = [l for l in logs if l.date == today_str]
        today_emission = sum(l.carbon_emission for l in today_logs)
        
        last_7_logs = [l for l in logs if l.date in last_7_days]
        daily_average = sum(l.carbon_emission for l in last_7_logs) / 7 if last_7_logs else 0
        
        return AnalyticsModel(
            daily_emissions=daily_emissions,
            weekly_total=round(weekly_total, 3),
            monthly_total=round(monthly_total, 3),
            yearly_total=round(yearly_total, 3),
            monthly_emissions=monthly_emissions,
            emissions_by_appliance=emissions_by_appliance,
            top_appliances=top_appliances,
            highest_emission_appliance=highest_emission_appliance,
            today_emission=round(today_emission, 3),
            daily_average=round(daily_average, 3),
            total_carbon_emissions=round(total_carbon_emissions, 3)
        )

    def get_eco_tips(self, limit: int = 5) -> List[EcoTipModel]:
        import random
        return random.sample(self.eco_tips, min(limit, len(self.eco_tips)))


db = Database()
