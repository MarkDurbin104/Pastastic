// =======================================================
// FLASH STATE ENGINE
// FStEng.as
// This is the main code for the Flash State Engine, created
// by Jonathan Kaye to accompany the book, "Flash for Interactive Simulation"
// (October, 2002), by Jonathan Kaye and David Castillo
// (Delmar Thomson Learning).
// 
// You may use and modify this code as you wish so long as
// this header remains.  The code is supplied as-is.  For
// questions or comments, please refer to www.FlashSim.com.
// =======================================================
// 12/01/01: JMK Created.
// =======================================================

// CONSTRUCTOR
_global.state_engine = function (n, id, tl) {
	this.name = n;
	this.id = id;
	this.listeners = this.oracle = this.st_net = null;
	this.active = false;
	this.timeline = tl;
}

state_engine.prototype.set_state_network = function (sn) {
	this.st_net  = sn;
}

// REM_STATE_ENGINE - Remove memory associated with the state engine
// passed in, then delete the state engine itself.
_global.rem_state_engine = function (se) {
	var i;

	if (se.st_net instanceof hstate || se.st_net instanceof hstate_c)
		rem_hstate(se.st_net);
	else 
		rem_state(se.st_net);

	if (se.listeners != null) {
		for (i=0; i<se.listeners.length; i++)  {
			delete se.listeners[i];
		}
		delete se.listeners;
	}

}

// ACTIVATE - Activates the state engine.  If 'noHistReset' is present and true,
// don't reset the history mechanism for the whole network.  You usually want to
// allow the resetting.
state_engine.prototype.activate = function (noHistReset) {
	var i, j;

	this.active = true;

	// Clear all history variables to restart anew
	if (noHistReset == undefined || noHistReset == false) {
		for (i in this.st_net.substates) {
			if (this.st_net.substates[i] instanceof hstate) {
				this.st_net.substates[i].st_mgr.reset_history();
			} else if (this.st_net.substates[i] instanceof hstate_c) {
				for (j in this.st_net.substates[i].st_mgrs) {
					this.st_net.substates[i].st_mgrs[j].reset_history();
				}
			}
		}

	}
	this.onActivate();
	this.st_net.enter();
	
}

// DEACTIVATE
state_engine.prototype.deactivate = function () {
	this.st_net.leave();
	this.onDeactivate();
	this.active = false;
}

// default onActivate
state_engine.prototype.onActivate = function () {
	trace("< State Engine '" + this.name + "' is being ACTIVATED >");
}


// default onDeactivate
state_engine.prototype.onDeactivate = function () {
	trace("< State Engine '" + this.name + "' has been DEACTIVATED >");
}


// ADDLISTENER
state_engine.prototype.addListener = function (fn) {
	var x;

	if (this.listeners == null)
		this.listeners = new Array();

	// Validate the existence of the listener function or method
	 if (!(fn instanceof Function) && (fn.ieh == undefined)) {
		trace("ERR002: addListener Error!  listener fn passed in is invalid");
		return;
	} 

	this.listeners.push(fn);
}


state_engine.prototype.removeListener = function(fn) {
	var i;

	for (i=0; i<this.listeners.length; i++) {
		if (this.listeners[i] == fn) {
			this.listeners.splice(i, 1);
			return true;
		}
	}
	
	trace("ERR103: Method removeListener called to remove listener, but not found on state engine " + this.name);
	return false;
}

// SETORACLE
state_engine.prototype.setOracle = function (fn) {
	var rv = (oracle == null);

	if (!(fn instanceof Function) && (fn.irh == undefined)) {
		trace("ERR016: setOracle Error!  oracle fn passed in is invalid");
		return;
	}

	this.oracle = fn;

	if (!rv)
		trace("WARN002: Oracle for state engine " + this.name + " is being reset.");

	return rv;
}


// NOTIFYLISTENERS.  Expects at least an event id and an optional value, may be more
state_engine.prototype.notifyListeners = function (eid, val) {
	var i, li;

	for (i=0; i<this.listeners.length; i++) {
		li = this.listeners[i];
		if (li instanceof Function) {
			li.apply(this, arguments);;
		} else {
			li.ieh.apply(li, arguments);
		}
	}
}

// ASKORACLE.  Expects at least a request id and an optional value, may be more
state_engine.prototype.askOracle = function (rid, val) {
	var orc;

	if (this.oracle == undefined) {
		trace("ERR102: State Engine " + this.name + " made oracle request but no oracle set");
		return undefined;
	} else {
		orc = this.oracle;
		if (orc instanceof Function) {
			return (orc.apply(this, arguments));
		} else {
			return (orc.irh.apply(orc, arguments));
		}
	}
}

// IEH
state_engine.prototype.ieh = function (eid, val) {
	trace("Default State Engine IEH called with <" + eid + ", " + val + ">, passing to listeners");
	this.notifyListeners(eid, val);
}

// XEH
state_engine.prototype.xeh = function (eid, val) {
	trace("Default State Engine XEH called with <" + eid + ", " + val + ">");
}

// IRH
state_engine.prototype.irh = function (rid, val) {
	trace("Default State Engine IRH called with <" + rid + ", " + val + ">");
	return ( this.oracle == null ? undefined : this.askOracle(rid, val));
}

// XRH
state_engine.prototype.xrh = function (rid, val) {
	trace("Default State Engine XRH called with <" + rid + ", " + val + ">");
	return(undefined);
}


// *******************************************************
// *******************************************************
// STATE MANAGER
// *******************************************************
// *******************************************************

// =======================================================
// 12/01/01: JMK Created.
// =======================================================

// STATE_MGR CONSTRUCTOR
// name - State manager name
// id - numeric id for the state manager
// def_st - default start state (id #)
// cont_st - Pointer to state containing this manager.  'null' if this is manager at state engine (top) level.
// cs - current (sub) state (id #)
// last_st - last state entered (for history mechanism)
_global.state_mgr = function (id, n, default_state, container_state) {
	this.name = n;
	this.id  = id;
	this.def_st = default_state;
	this.cont_st = container_state;
	this.cs  = undefined;
	this.last_st = undefined;

	if (id == null || default_state == null || container_state == null) {
		trace("ERR003: State Manager Constructor Error!  " + n + "'s id, default state, and container state must be non-null");
		return;
	}

	// Register this state manager with the state network
	if (container_state instanceof hstate_c) {
		container_state.add_sm(this);
	} else {
		// The container is an hstate -- use set_sm
		container_state.set_sm(this);
	}
}


/* ACTIVATE
Called when the state engine activates the state network that we (this state manager)
manage.  Our job is to activate the network by entering a state.  We can either
- Enter the default start state;
- Enter the state that was current before we were last deactivated (history mechanism);
- Enter a specific state as given by spec_ids.

If hist is true, we should enter the state most recently visited (last_st). If false,
enter the default start state (def_st). If spec_ids is present (not null), we ignore
the default start state, we ignore the hist flag, and spec_ids is an array of state id's,
with the first element being the numeric id of the state we're supposed to enter.
This is to handle transitions that span state levels.
*/
_global.state_mgr.prototype.activate = function(hist, spec_ids) {
	var ns;

	trace("State Manager " + this.name + " ACTIVATING" + (hist ? " (history == true)" : ""));

	// determine which state to start in.  If spec_ids is non-null, use it
	if (spec_ids != null) {
		// Take off the first state in the state path.  This is for our level.
		this.cs = spec_ids[0];
		spec_ids.splice(0, 1);
		if (spec_ids.length == 0) {
			delete spec_ids;
			spec_ids = null;
		}
	} else {
		// Use the history mechanism if caller wants, otherwise use default start state
		this.cs = ((hist && this.last_st != undefined) ? this.last_st : this.def_st);
		// Clear the hist value because we just used it if we were supposed to
		hist = false;
	}

	// If last state visited is undefined, set it to the current state so we don't lose track of the last state visited
	if (this.last_st == undefined) {
		this.last_st = this.cs;
	}

	// Retrieve appropriate state to enter then do the deed!
	ns = this.cont_st.substates[this.cs];
	ns.enter(hist, spec_ids);
}



// DEACTIVATE - Called when the network this state manager manages is deactivated (because
// the state engine has left the state that contains us).
_global.state_mgr.prototype.deactivate = function  () {
	var sp;

	trace("State Manager " + this.name + " DEACTIVATING");
	if (this.cs != undefined) {
		sp = this.cont_st.substates[this.cs];
		sp.leave();

		// Record last state entered before we get deactivated
		this.last_st = this.cs;

		this.cs = undefined; // Reset current state
	}
}

// RESET_HISTORY - walks through the states controlled by this manager and sub-managers
// and clears the history variable (last_st) so that next time through this state network,
// the last state visited will be undefined.
_global.state_mgr.prototype.reset_history = function () {
	var i, sp;

	// if history mechanism already null, don't waste time resetting sub-states
	if (this.last_st == undefined)
		return;

	this.last_st = undefined;
	for (i in this.cont_st.substates) {
		sp = this.cont_st.substates[i];
		if (sp instanceof hstate) {
			sp.st_mgr.reset_history();
		} else if (sp instanceof hstate_c) {
			for (j in sp.st_mgrs) {
				if (sp.st_mgrs[j] instanceof state_mgr) {
					sp.st_mgrs[j].reset_history();
				}
			}
		}
	}

}

// CHG_ST - Change the current state along transition with id # 'trans'.
// if net_lvl is true, it is a transition off of the state network level (container state) into the state network.  The third parameter, 'val', is an optional argument that
// is passed to the transition function.
//
_global.state_mgr.prototype.chg_st = function  (trans_id, net_lvl, val) {
	var stp, trans, ts, cpy_st_path, nsm, i, tmpcs;
	
	stp =  this.cont_st.substates[this.cs];

	if (net_lvl) {
		trace("CHG_ST: Changing from state #" + this.cont_st.id + " along transition #" + trans_id);
		ts = this.cont_st;
	} else {
		trace("CHG_ST: Changing from state #" + this.cs + " along transition #" + trans_id);
		ts = stp;
	}

	
	// Steps:
	// 1. Leave current state
	// 2. Execute transition actions
	// 3. Enter new state

	// RETRIEVE TRANSITION ACTIONS
	trans = ts.transitions[trans_id];

	if (trans == undefined) {
		trace("ERR104: Error in chg_st!  Change cancelled.  No transition #" + trans_id + " for current state " + st.name);
	} else {
		// If this is a simple transition, move at current level.  Otherwise do the jumping necessary.
		// Don't forget to respect the history mechanism, if transition tagged as such (trans.hist).
		if (!(trans instanceof trans_lvl)) {
			if (trans.hist && stp.my_sm.cont_st.st_mgrs != undefined) {
				// This is a state in an hstate_c that is trying to use the history mechanism.
				// If we used the default behavior, only this state network would go to its
				// last state.  That would be neat except that we have to be consistent with
				// the way history works for jumps into the hstate_c, which is to instruct all
				// state managers for this hstate_c to use their history mechanism.
				stp = stp.my_sm.cont_st;
				// LEAVE CURRENT
				for (i in stp.st_mgrs) {
					stp.substates[stp.st_mgrs[i].cs].leave();

					// make sure we set last_st and current state (cs) properly
					tmpcs = stp.st_mgrs[i].cs;
					stp.st_mgrs[i].cs = stp.st_mgrs[i].last_st;
					stp.st_mgrs[i].last_st = tmpcs;
				}

				// EXECUTE TRANSITION ACTIONS
				if (trans.xfn instanceof Function) {
					trans.xfn(val);
				}
				
				for (i in stp.st_mgrs) {
					stp.substates[stp.st_mgrs[i].cs].enter(true, null);
				}
			} else {
				// Great!  We know we're doing a simple transition now without the hassle above.
				// LEAVE CURRENT
				stp.leave();

				// EXECUTE TRANSITION ACTIONS
				if (trans.xfn instanceof Function) {
					trans.xfn(val);
				}

				// Before we set a new state
				// Set the TO state.  If we're supposed to use the history mechanism,
				// that supercedes a value in the to_st slot.
				if (trans.hist == true) {
					this.cs = this.last_st;
				} else {
					if (this.cs != undefined)
						this.last_st = this.cs;
					this.cs = trans.to_st;
				}

				// ENTER NEW STATE
				stp = this.cont_st.substates[this.cs];
				stp.enter(trans.hist, null);
			}
		} else {
			// We've got a Transition Level Jump -- handle it here
			if (trans.st_path != null) {
				// If there is a path to traverse, copy the contents to a new array because we
				// will progressively delete from the array we pass as transitions occur.
				cpy_st_path = new Array();
				for (i=0; i<trans.st_path.length; i++)
					cpy_st_path.push(trans.st_path[i]);
			} else {
				cpy_st_path = null;
			}

			// LEAVE CURRENT STATE and any ancestors up to common parent state manager
			if (trans.up_lvls > 0) {
				nsm = this.pass_up(trans.up_lvls);
			} else {
				nsm = this;
				stp.leave();
				if (cpy_st_path != null)
					nsm.last_st = stp.id;
			}

			// EXECUTE TRANSITION ACTIONS 
			if (trans.xfn instanceof Function) {
				trans.xfn(val);
			}

			// Update current state if we're supposed to go down into a specific state
			if (cpy_st_path != null)
				nsm.cs = cpy_st_path[0];

			// now have to follow state path downward
			nsm.pass_down(cpy_st_path, trans.hist);
		}
	}
}

// PASS_UP - Used by chg_st() to effect the transition to a state whose common
// ancestor/parent with the current state is above the current state manager.
// Called when state transition causes us to leave our level and some
// number of levels above us.  Go up the state network, leaving each container
// state, until we reach the appropriate level.  Return the state manager at this level.
_global.state_mgr.prototype.pass_up = function (up_lvls) {
	var nsm = this;

	while (up_lvls > 0) {
		nsm.cont_st.leave();
		up_lvls--;
		// The container state's network is now in limbo as we've left the current
		// state.  We put it in limbo so that if a parent manager tries to deactivate
		// concurrent states, our network will not be re-"leave"d.
		nsm.cont_st.my_sm.last_st = nsm.cont_st.my_sm.cs;
		nsm.cont_st.my_sm.cs = undefined;
		nsm = nsm.cont_st.my_sm;

		if (nsm == null) {
			trace("ERR101: pass_up reached top of state network.  Check up levels in transtion.");
		}
	}

	return nsm;
}

// PASS_DOWN - Used by chg_st() and pass_up() to make transitions that jump to levels
// within a sibling state but below the current level.
_global.state_mgr.prototype.pass_down = function (st_path, hist) {
	var stp;

	if (st_path == null || st_path.length < 1) {
		delete st_path;
		if (hist == false) {
			if (this.last_st != undefined) {
				trace("WARN100: Warning from pass_down!  did you mean to pass a null state path and no history set?  Entering default start state");
				this.last_st = this.def_st;
			} else {
				trace("ERR100: Error from pass_down! Received a null state path, history false, and no last state to enter.");
				return;
			}
		} 
		stp = this.cont_st.substates[this.last_st];
		stp.enter(hist, null);
		stp.my_sm.cs = stp.id;
	} else {
		stp = this.cont_st.substates[st_path[0]];
		st_path.splice(0, 1);
		if (st_path.length == 0) {
			// We've reached the right level
			// ENTER the target state
			stp.enter(hist, null);
			delete st_path;

		} else {
			stp.enter(hist, st_path);
		}
	}
}

// *******************************************************
// *******************************************************
// STATES, HSTATE, HSTATE_C
// *******************************************************
// *******************************************************

// =======================================================
// 12/01/01: JMK - Created
// =======================================================

// STATE CLASS

// Constructor
// nm: state name
// id: numeric id for state (must be unique within sibling states in state engine)
// msm: pointer to state manager that manages us. If null, this is top state.
_global.state = function (nm, id, msm) {
	var rv;

	this.name = nm;
	this.id = id;
	this.my_sm = msm;
	if (id == null) {
		trace("ERR005: State Constructor Error: id for state " + nm + " passed in as null");
	} else if (msm != null) {
		rv = msm.cont_st.add_subst(this, id);
		if (rv != true) {
			trace("ERR006: State Constructor Error: Failed to add " + nm + " to container state");
		}
	}	
	this.transitions = this.intActs = this.pActvies = this.cActvies = null;
}

// REM_STATE - deletes memory associated with the state s.  If delItself is false,
// don't delete the state object itself.  This is for the hstate to delete state memory
// but not the object (let rem_hstate()) do that.
_global.rem_state = function (s, delItself) {
	var i;

	if (s.transitions != null) {
		for (i in s.transitions) {
			if (s.transitions[i] instanceof trans)
				rem_trans(s.transitions[i]);
		}
		delete s. transitions;
	}
	if (s.intActs != null) {
		delete s.intActs;
	}
	if (s.pActvies != null) {
		for (i in s.pActvies) {
			delete s.pActvies[i];
		}
		delete s.pActvies;
	}
	if (s.cActvies != null) {
		for (i in s.cActvies) {
			delete s.cActvies[i];
		}
		delete s.cActvies;
	}

	// finally delete the state object itself
	if (delItself != false)
		delete s;
}

// ENTER state - called when state entered
state.prototype.enter = function () {

	// trace(">>>> Default Enter State: " + this.name + " (" + this.id + ")");
	this.entActs();
	this.start_state_activities();
}

// START_STATE_ACTIVITIES : Start any pulse or continuous state activities
// for this state
state.prototype.start_state_activities = function () {
	var i, pa;

	// Queue any pulse activities for this state
	if (this.pActvies != null) {
		for (i in this.pActvies) {
			pa = this.pActvies[i];
			if (pa.intvl != undefined) {
				if (pa.obj == undefined) {
					pa.intvlID = setInterval(pa.fn, pa.intvl);
				} else {
					pa.intvlID = setInterval(pa.obj, pa.fn, pa.intvl);
				}
			}
		}
	}

	// Activate any continuous activities for this state
	if (this.cActvies != null) {
		for (i in this.cActvies) {
			this.cActvies[i].mc.gotoAndPlay(2);
			this.cActvies[i].mc._visible = true;
		}
	}
}

// ENTACTS - actions executed when entering state
state.prototype.entActs = function () {
	trace(">>>> Default Enter Actions for State: " + this.name + " (" + this.id + ")");
}

// LEAVE state - called when state left
state.prototype.leave = function () {
	var i;

	// trace("<<<< Default Leave State: " + this.name + " (" + this.id + ")");
	this.stop_state_activities();
	this.lvActs();
}

state.prototype.stop_state_activities = function () {
	var i, tc;

	// turn off mode activities
	if (this.pActvies != null) {
		for (i in this.pActvies) {
			pa = this.pActvies[i];
			if (pa.intvl != undefined) {
				clearInterval(pa.intvlID);
				pa.intvlID = undefined;
			}
		}
	}

	// Deactivate any continuous activities for this state
	if (this.cActvies != null) {
		for (i in this.cActvies) {
			this.cActvies[i].mc.gotoAndStop(1);
			this.cActvies[i].mc._visible = !this.cActvies[i].hideClip;
		}
	}
}

// LVACTS - actions executed when leaving state
state.prototype.lvActs = function () {
	trace("(default) Leave Actions for state: " + this.name);
}


// CHG_ST - change state using transition trans_i, with an optional value for the
// transition function as a second argument.
//
// As you can see from the code, this function passes the information
// to the chg_st method of the state manager to do the real work.  The reason we define
// this dummy is so that modelers see the direct relationship to the transition id,
// which is unique by state.  For example, if a caller wants to change the current state,
// state 2, using transition 0, the caller would write:
//
//   state2.chg_st(0);
// 
// This implies that the transition 0 is relative to the state.  The same unaltered call
// would be
//
//  sm.chg_st(0);
// 
// in which 'sm' is the state manager of state 2 and its siblings.  It is less obvious from the
// second form that the processor is using the current state (2)'s transition 0, as opposed
// to, perhaps, state 1 or 6's transition with id 0.
// 
// The second argument, val, is an optional value to send in to the transition function.

state.prototype.chg_st = function (trans_id, val) {
	// Determine whether this is a transition from this state or jump deeper into the state
	if ((this.transitions[trans_id] instanceof trans_lvl) && this.transitions[trans_id].up_lvls == -1) {
		// transition into the state
		if (this.substates == undefined) {
			trace("ERR017: Invalid chg_st for state " + this.name + " -- trying to jump within a simple state");
			return;
		}
		if (this.transitions[trans_id].st_path != null) {
			this.substates[this.transitions[trans_id].st_path[0]].my_sm.chg_st(trans_id, true, val);
		} else {
			// It must be a transition to history, so use all state manager
			// Replace in Flash 6 with instanceof
			if (this.st_mgr instanceof state_mgr) {
				this.st_mgr.chg_st(trans_id, true, val);
			} else {
				for (i in this.st_mgrs) {
					if (this.st_mgrs[i].id != undefined) {
						this.st_mgrs[i].chg_st(trans_id, true, val);
					}
				}
			}
		}
	
	} else {
		this.my_sm.chg_st(trans_id, false, val);
	}
}

// isActive - convenience function.  Returns true if this state is currently active,
// false if not.
state.prototype.isActive = function () {
	return (this.my_sm.cs == this.id);
}


// ADD_TRANS - add a transition out of this state
state.prototype.add_trans = function (id, trans) {
	if (this.transitions == null)
		this.transitions = new Object();

	if (this.transitions[id] == undefined) {
		this.transitions[id] = trans;
	} else {
		// defined already -- issue warning
		trace("ERR007: Add State Transition Error: duplicate ID (" + id + ") for state '" + this.name + "'");
	}
}

// ADD_INTACTS - add internal actions for the state
state.prototype.add_intAct = function (id, actfn) {

	if (this.intActs == null)
		this.intActs = new Object();

	if (this.intActs[id] == undefined) {
		this.intActs[id] = actfn;
	} else {
		// defined already -- issue warning
		trace("ERR008: Add State Internal Actions Error: duplicate ID (" + id + ")");
	}
}

// EXEC_IA - executes internal action with id for the state
// Can't do error checking in Flash 5 because this.intActs[id] is a function and 
// there's a bug that makes intActs[id] == null. We should use typechecking in Flash 6
state.prototype.exec_ia = function (id, val) {
	this.intActs[id](val);
}

// ADD_PULSE_ACTIVITY - add state activity for the state
state.prototype.add_pulse_activity = function (id, intvl, fnOrMet, obj) {
	var sar; // state activity record

	if (this.pActvies == null)
		this.pActvies = new Object();

	// SAR will hold a record that has the state activity function and id
	sar = new Object();
	sar.intvl = intvl; // in seconds
	sar.obj = obj;  // Object that has method to call (if function passed in, obj is undefined)
	sar.fn = fnOrMet;  // function to call or object that contains method to call

	if (this.pActvies[id] == undefined) {
		this.pActvies[id] = sar;
	} else {
		// defined already -- issue warning
		trace("ERR009: Add (Pulse) State Activity Error: duplicate ID (" + id + ")");
	}
}

// REMOVE_PULSE_ACTIVITY - removes state activity from the state
state.prototype.rem_pulse_activity = function (id) {
	delete this.pActvies[id];
}

// ADD_CONTIN_ACTIVITY - add continuous state activity for the state
state.prototype.add_contin_activity = function (id, mclip, hideClip) {
	var sar; // state activity record

	if (this.cActvies == null)
		this.cActvies = new Object();

	// SAR will hold a record that has the state activity function and id
	sar = new Object();
	sar.mc = mclip;
	sar.hideClip = hideClip;

	if (this.cActvies[id] == undefined) {
		this.cActvies[id] = sar;
		mclip._visible = !hideClip;
	} else {
		// defined already -- issue warning
		trace("ERR010: Add (Continuous) State Activity Error: duplicate ID (" + id + ")");
	}
}

// REMOVE_CONTIN_ACTIVITY - removes state activity from the state
state.prototype.rem_contin_activity = function (id) {
	delete this.cActvies[id];
}

// **************************
// HSTATE CLASS

// Constructor
// nm: state name
// id: numeric id for state (must be unique within sibling states in state engine)
// msm: pointer to state manager that manages us
_global.hstate = function(nm, id, msm) {
	super(nm, id, msm);
	this.st_mgr = null;
	this.substates = null;
}

// Setup inheritance for hstate
hstate.prototype = new state(null, 0);

// REM_HSTATE - remove the memory allocated for hstate or hstate_c s.
_global.rem_hstate = function (s) {
	var i;

	if (s instanceof hstate_c) {
		// s is an hstate_c
		for (i in s.st_mgrs) {
			delete s.st_mgrs[i];
		}
	} else {
		// s is an hstate
		delete s.st_mgr;
	}
	
	for (i in s.substates) {
		if (s.substates[i] instanceof hstate || s.substates[i] instanceof hstate_c) {
			rem_hstate(s.substates[i]);
			rem_state(s, false);
		} else {
			rem_state(s.substates[i]);
		}
	}

	delete s.substates;
	delete s;
}

// ADD_SUBST - Add a sub-state.  Returns true if successful, false if not
hstate.prototype.add_subst = function (st, id) {
	// check for duplicate ID
	if (typeof(this.substates[id])  == "object") {
		trace("ERR011: Error in hstate add_subst! Trying to add " + st.name + " to its container state " + this.name + " with the same id " + id);
		return false;
	}

	// Check that we have the state's state manager within this hstate
	if (this.st_mgr != st.my_sm) {
		trace("ERR012: Error in add_subst!  State " + st.name + "'s manager not found in hstate " + this.name + "'s state managers.");
		return false;
	}

	if (this.substates == null) {
		this.substates = new Object();
	}

	this.substates[id] = st;

	return true;
}

// SET_SM - sets the state manager.
hstate.prototype.set_sm = function (sm) {
	if (this.st_mgr != null) {
		trace("WARN001: Warning! Set State Manager (set_sm) for " + this.name + " is overwriting existing State Manager " + this.st_mgr + " with " + sm.name); 
	}
	this.st_mgr = sm;
}


// ENTER - called when a state is entered.  'hist' is true to use state history, false to use
// default start state.
// When we're told to jump into a specific sub-state, we don't want to allow the default start state or
// the history to get invoked.  'spec_ids' tells us which sub-state, if not == null, we're jumping into.
hstate.prototype.enter = function (hist, spec_ids) {

	// Flash 6 use super
	super.enter();

	if (this.st_mgr != null) {
		if (spec_ids)
			this.st_mgr.activate(hist, spec_ids);
		else
			this.st_mgr.activate(hist);
	}
}


// LEAVE - called when a state is left
hstate.prototype.leave = function () {
	this.st_mgr.deactivate();
	super.leave();
}


// **************************
// HSTATE_C CLASS

// Constructor
// nm: state name
// id: numeric id for state (must be unique within sibling states in state engine)
// msm: pointer to state manager that manages us
_global.hstate_c = function (nm, id, msm) {
	super(nm, id, msm);
	this.st_mgrs = null;
	this.substates = null;
}

// Setup inheritance for hstate_c
hstate_c.prototype = new state(null, 0);

// ADD_SUBST - Add a sub-state
hstate_c.prototype.add_subst = function (st, id) {

	// check for duplicate ID
	if (typeof(this.substates[id])  == "object") {
		trace("ERR013: Error in hstate_c add_subst! Trying to add a sub-state of '" + this.name + "' with the same id (" + id + ")");
		return false;
	}

	// Check that we have the state's state manager within this hstate
	if (this.st_mgrs[st.my_sm.id] != st.my_sm) {
		trace("ERR014: Error in hstate_c add_subst!  State " + st.name + "'s manager not found in container hstate_c " + this.name + "'s state managers.");
		return false;
	}

	if (this.substates == null) {
		this.substates = new Object();
	}

	this.substates[id] = st;

	return true;
}


// ADD_SM - add state manager.  Adds a state manager object to the hierarchical
// state.
hstate_c.prototype.add_sm = function (sm) {
	var id = sm.id;

	if (this.st_mgrs == null) {
		this.st_mgrs = new Object();
	}

	if (this.st_mgrs[id] == undefined) {
		this.st_mgrs[id] = sm;
	} else {
		// defined already -- issue warning
		trace("ERR015: Add State Manager Error: duplicate ID (" + id + ") for state '" + this.name + "'");
	}
}


// ENTER - called when a state is entered.  'hist' is true to use state history, false to use
// default start state.
// When we're told to jump into a specific sub-state, we don't want to allow the default start state or
// the history to get invoked.  'spec_ids' tells us which sub-state, if not == null, we're jumping into.
// Therefore, for the state manager of that sub-state, we call activate() with this special 
// sub-state id.
hstate_c.prototype.enter = function (hist, spec_ids) {
	var i, js = null, sm;

	super.enter();

	// If this is a special jump, record which state manager not to activate as normal
	if (spec_ids != null) {
		js = this.substates[spec_ids[0]];
		js = js.my_sm;
	}

	// Activate the state managers. Arbitrarily, we activate all the state managers
	// (and consequently their lower level states) before we activate the state manager
	// along the branch that contains the special ids (state path).
	if (this.st_mgrs != null) {
		for (i in this.st_mgrs) {
			sm = this.st_mgrs[i];
			if (sm != null) {  // do type checking in Flash 6
				if (spec_ids == null) {
					sm.activate(hist, null);
				} else if (js != sm) {
					// history only applies to the last state on the path we're taking on spec_ids, so
					// if we're activating a state manager not on this path, don't
					// pass along the history flag.
					sm.activate(false, null);
				}
			}
		}
		if (spec_ids != null) {
			js.activate(hist, spec_ids);
		}
	}
}


// LEAVE - called when the state is left
hstate_c.prototype.leave = function () {
	var i, sm;

	// deactivate all the state manager
	if (this.st_mgrs != null) {
		for (i in this.st_mgrs) {
			sm = this.st_mgrs[i];
			if (sm instanceof state_mgr) {
				sm.deactivate();
			}
		}
	}

	super.leave();
}

// *******************************************************
// *******************************************************
// TRANSITIONS
// *******************************************************
// *******************************************************

// =======================================================
// 12/01/01: JMK Created.
// =======================================================

// **************************
// TRANS CLASS

// CONSTRUCTOR
// id - numeric id of this transition
// to_st - A numeric id for the state to which this transition goes.
// xfn - function to execute on this transition 
_global.trans = function(xfn, to_state, hist) {
	this.to_st = to_state;
	this.hist = (hist == true);
	this.xfn = xfn;
}

// REM_TRANS - Remove any memory (cleanup) we allocated for this transition
_global.rem_trans = function(tr) {
	if (tr.st_path instanceof trans_lvl)
		delete tr.st_path;

	delete tr;
}


// **************************
// TRANS_LVL CLASS
// A transition that jumps out of the current state engine (either up or down in the state engine).
// up_lvls - number of levels to ascend to reach parent of this state and target state
// st_path - array of values either down to the destination state (in order of traversal,
// top to bottom), or from the common parent state (common to current and destination) down to the destination state (in order of traversal, top to bottom).
_global.trans_lvl = function (xfn, levels_up, state_path, hist) {
	super(xfn, null, hist);
	this.up_lvls = levels_up;
	this.st_path = state_path;
}


// **************************
// Setup chain that allows trans_lvl to inherit from trans.
trans_lvl.prototype = new trans();
