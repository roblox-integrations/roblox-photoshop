import React from "react";

import "./styles.css";
import { PanelController } from "./controllers/PanelController.jsx";
import { CommandController } from "./controllers/CommandController.jsx";
import { About } from "./components/About.jsx";
import { Demos } from "./panels/Demos.jsx";
import { MainPanel } from "./panels/MainPanel.jsx";

import { entrypoints } from "uxp";

const aboutController = new CommandController(
  ({ dialog }) => <About dialog={dialog} />,
  {
    id: "showAbout",
    title: "React Starter Plugin Demo",
    size: { width: 480, height: 480 },
  }
);

const moreDemosController = new PanelController(() => <MainPanel />, {
  id: "mainPanel",
  menuItems: [
    {
      id: "reload2",
      label: "Reload Plugin",
      enabled: true,
      checked: false,
      oninvoke: () => { console.log("onInvoke"); location.reload()},
    },
    {
      id: "dialog1",
      label: "About",
      enabled: true,
      checked: false,
      oninvoke: () => aboutController.run(),
    },

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
    showAbout: aboutController,
  },
  panels: {
   // demos: demosController,
    moreDemos: moreDemosController,
  },
});
