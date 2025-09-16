import 'package:flutter/material.dart';
import 'package:eco_sustain/components/learninghub/guide_detail_screen.dart';

class GuidesData {
  // 📱 Smartphone Recycling Guide
  static final smartphoneRecyclingSteps = [
    GuideStep(
      icon: Icons.smartphone,
      title: "Getting Started",
      description:
          "Welcome to your smartphone recycling journey! This guide will walk you through the safe and responsible way to recycle your old device while protecting your personal information.",
    ),
    GuideStep(
      icon: Icons.lock,
      title: "Remove Personal Data",
      description:
          "Before recycling, ensure all personal data is erased. Perform a factory reset and remove accounts linked to the device.",
    ),
    GuideStep(
      icon: Icons.sim_card,
      title: "Remove SIM and Memory Cards",
      description:
          "Take out your SIM card and any external memory cards. These may contain personal data and should not be recycled with the phone.",
    ),
    GuideStep(
      icon: Icons.battery_full,
      title: "Check Battery Condition",
      description:
          "Ensure the battery is intact and not swollen or damaged. If damaged, inform the recycling center as it requires special handling.",
    ),
    GuideStep(
      icon: Icons.power,
      title: "Gather Accessories",
      description:
          "Collect chargers, earphones, and cables. Many recycling programs accept these items and recover valuable materials.",
    ),
  ];

  // ☀️ Solar Energy Guide
  static final solarEnergySteps = [
    GuideStep(
      icon: Icons.sunny,
      title: "Assess Energy Needs",
      description:
          "Calculate your household’s daily energy consumption before choosing a solar setup.",
    ),
    GuideStep(
      icon: Icons.home,
      title: "Roof & Space Check",
      description:
          "Evaluate your roof’s orientation, angle, and space. Ensure it gets enough direct sunlight for efficient solar collection.",
    ),
    GuideStep(
      icon: Icons.settings,
      title: "Choose Equipment",
      description:
          "Select the right solar panels, inverter, and battery system based on your energy needs and budget.",
    ),
    GuideStep(
      icon: Icons.engineering,
      title: "Professional Installation",
      description:
          "Hire certified installers to ensure your system is safe and efficient.",
    ),
    GuideStep(
      icon: Icons.monitor,
      title: "Monitoring & Maintenance",
      description:
          "Use monitoring apps to track production and schedule regular cleaning of panels to maintain efficiency.",
    ),
  ];

  // 🌍 Carbon Footprint Guide
  static final carbonFootprintSteps = [
    GuideStep(
      icon: Icons.calculate,
      title: "Calculate Your Emissions",
      description:
          "Start by calculating your carbon footprint using online tools or mobile apps.",
    ),
    GuideStep(
      icon: Icons.directions_car,
      title: "Transportation Choices",
      description:
          "Switch to carpooling, biking, walking, or public transit. Consider electric or hybrid vehicles.",
    ),
    GuideStep(
      icon: Icons.home,
      title: "Home Energy Use",
      description:
          "Reduce household energy consumption by switching to LED lights, improving insulation, and using smart thermostats.",
    ),
    GuideStep(
      icon: Icons.fastfood,
      title: "Diet & Lifestyle",
      description:
          "Eat more plant-based meals and reduce food waste. Local produce has a smaller carbon footprint.",
    ),
    GuideStep(
      icon: Icons.restore,
      title: "Offset & Track",
      description:
          "Consider carbon offset programs and track your progress to stay motivated.",
    ),
  ];

  // 💻 Extend Device Lifespan
  static final extendDeviceSteps = [
    GuideStep(
      icon: Icons.cleaning_services,
      title: "Keep Devices Clean",
      description:
          "Regularly clean your devices to prevent dust buildup and overheating.",
    ),
    GuideStep(
      icon: Icons.battery_charging_full,
      title: "Battery Care",
      description:
          "Avoid overcharging. Keep devices between 20–80% charge for better battery health.",
    ),
    GuideStep(
      icon: Icons.system_update,
      title: "Software Updates",
      description:
          "Update your device regularly to improve security, performance, and compatibility.",
    ),
    GuideStep(
      icon: Icons.build,
      title: "Repair Instead of Replace",
      description:
          "Fix small issues like screen or battery replacements instead of buying a new device.",
    ),
    GuideStep(
      icon: Icons.handshake,
      title: "Donate or Reuse",
      description:
          "Donate working devices to schools or charities before discarding them.",
    ),
  ];

  // 🔄 Recycling Electronics Responsibly
  static final recyclingElectronicsSteps = [
    GuideStep(
      icon: Icons.search,
      title: "Find a Certified Recycler",
      description:
          "Locate certified e-waste recycling centers in your area to ensure proper handling.",
    ),
    GuideStep(
      icon: Icons.delete,
      title: "Data Wiping",
      description:
          "Clear all data from devices before sending them to recyclers to protect your privacy.",
    ),
    GuideStep(
      icon: Icons.storage,
      title: "Separate Components",
      description:
          "Keep batteries, cables, and devices separate for easier recycling.",
    ),
    GuideStep(
      icon: Icons.local_shipping,
      title: "Drop-off or Pickup",
      description:
          "Some centers provide pickup services; otherwise, drop off your devices safely.",
    ),
    GuideStep(
      icon: Icons.eco,
      title: "Confirm Recycling",
      description:
          "Ensure your devices are processed and not resold or exported unsafely.",
    ),
  ];

  // 🖥️ Laptop Refurbishing Guide
  static final laptopRefurbishingSteps = [
    GuideStep(
      icon: Icons.laptop,
      title: "Initial Inspection",
      description:
          "Check the laptop for physical damage, missing parts, or swollen batteries.",
    ),
    GuideStep(
      icon: Icons.cleaning_services,
      title: "Clean Thoroughly",
      description:
          "Dust off vents, fans, and keyboards. Apply fresh thermal paste if necessary.",
    ),
    GuideStep(
      icon: Icons.memory,
      title: "Upgrade Hardware",
      description:
          "Replace HDD with SSD and upgrade RAM to improve speed and performance.",
    ),
    GuideStep(
      icon: Icons.system_update,
      title: "Install Operating System",
      description:
          "Reinstall or upgrade to a lightweight OS to give the laptop a fresh start.",
    ),
    GuideStep(
      icon: Icons.done,
      title: "Final Testing",
      description:
          "Run diagnostics, check ports, and ensure battery health before use or resale.",
    ),
  ];

  // 🏠 Smart Home Energy Monitoring
  static final smartHomeSteps = [
    GuideStep(
      icon: Icons.sensors,
      title: "Select Monitoring Devices",
      description:
          "Choose smart plugs, energy monitors, or integrated home systems.",
    ),
    GuideStep(
      icon: Icons.settings_remote,
      title: "Install & Configure",
      description:
          "Set up devices with your Wi-Fi and connect them to your smartphone apps.",
    ),
    GuideStep(
      icon: Icons.insights,
      title: "Track Energy Use",
      description:
          "View real-time consumption and identify high-energy appliances.",
    ),
    GuideStep(
      icon: Icons.tips_and_updates,
      title: "Optimize Usage",
      description:
          "Automate schedules, turn off unused devices, and set energy-saving goals.",
    ),
    GuideStep(
      icon: Icons.eco,
      title: "Sustainable Living",
      description:
          "Use insights to make long-term eco-friendly changes, reducing costs and emissions.",
    ),
  ];

  /// Match guide title to its steps
  static List<GuideStep> getStepsForTitle(String title) {
    switch (title) {
      case "Smartphone Recycling Guide":
        return smartphoneRecyclingSteps;
      case "Complete Guide to Solar Energy for Your Home":
        return solarEnergySteps;
      case "Understanding Your Carbon Footprint":
        return carbonFootprintSteps;
      case "Extend your device lifespan":
        return extendDeviceSteps;
      case "Recycling electronics responsibly":
        return recyclingElectronicsSteps;
      case "Laptop Refurbishing Guide":
        return laptopRefurbishingSteps;
      case "Smart Home Energy Monitoring Setup":
        return smartHomeSteps;
      default:
        return [];
    }
  }
}
