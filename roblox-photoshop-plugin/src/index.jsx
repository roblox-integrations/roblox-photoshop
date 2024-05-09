import React from "react";

import "./styles.css";
import { PanelController } from "./controllers/PanelController.jsx";
import { MainPanel } from "./panels/MainPanel.jsx";

import { entrypoints } from "uxp";


const moreDemosController = new PanelController(() => <MainPanel />, {
  id: "mainPanel",
  menuItems: [
    {
      id: "reload2",
      label: "Reload Plugin",
      enabled: true,
      checked: false,
      oninvoke: () => { console.log("onInvoke"); location.reload()},
    }
  ],
});

entrypoints.setup({
  plugin: {
    create(plugin) {
      /*optional */ console.log("created", plugin);
    },
    destroy() {
      /*optional */ console.log("destroyed");
    },
  },
  commands: {
  },
  panels: {
    moreDemos: moreDemosController,
  },
});
